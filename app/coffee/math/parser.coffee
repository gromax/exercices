
ParseManager = {
	initOk:false
	initParse: ->
		@initOk = true
		# Pour éviter d'alourdir le constructor dans le cas où la classe ne servirait à aucun parse
		# Initialisation du parser
		@Tokens = [TokenNumber, TokenParenthesis, TokenOperator, TokenFunction, TokenVariable, TokenEnsembleDelimiter]
		@globalRegex = new RegExp ( "(#{oToken.getRegex()})" for oToken in @Tokens ).join("|"), "gi"
	typeToStr: (type) ->
		switch type
			when "number" then "nombre"
			when "ensemble" then "ensemble"
			when "equation" then "équation"
			else "(#{type} ?)"
	parse: (expression,type, info) ->
		if @initOk is false then @initParse()
		# Les élèves ont le réflexe d'utiliser la touche ² présente sur les claviers
		if typeof expression is "string"
			# Les élèves utilisent la touche ²
			expression = expression.replace /²/g, "^2 "
			# Dans certains cas, le - est remplacé par un autre caractère plus long
			expression = expression.replace /−/g, "-"
		matchList = expression.match(@globalRegex)
		if matchList?
			tokensList = @correction ( @createToken(strToken,type, info) for strToken in matchList ) , info
			switch
				when tokensList is null then false
				when tokensList.length is 0
					info.messages.push "Liste de tokens vide"
					false
				else
					rpn = @buildReversePolishNotation tokensList
					buildArray = @buildObject(rpn)
					output = buildArray.pop()
					# On vérifie que la sortie a la bonne forme
					switch
						when buildArray.length>0
							info.messages.push "La pile n'est pas vide"
							false
						when (type is "ensemble") and (output instanceof EnsembleObject) then output
						when (type is "number") and (output instanceof NumberObject) then output
						when (type is "equation") and (output instanceof Equation) then output
						else
							info.messages.push "Le résultat ne correspond pas à un(e) '#{@typeToStr(type)}'"
							false
		else
			info.messages.push "Vide !"
			false
	createToken: (tokenString,type, info) ->
		# tous les tokens doivent être reconnus
		# Une erreur crée un null qui lors de la correction provoquera l'erreur du parse
		for oToken in @Tokens when typeof (tokenStringRegex = oToken.getRegex(type)) is "string"
			regex = new RegExp(tokenStringRegex,'i')
			if regex.test(tokenString) then return new oToken(tokenString)
		info.messages.push "'#{tokenString}' n'est pas valide pour un(e) #{@typeToStr(type)}"
		null
	correction: (tokens, info) ->
		if ( oToken for oToken in tokens when not(oToken instanceof TokenObject) ).length>0 then return null
		# Vérification des bons positionnement des délimiters d'ensembles
		openedEnsemble = false
		for token in tokens when token instanceof TokenEnsembleDelimiter
			# On fixe le type, ouvrant fermant, et en cas d'erreur on sort
			unless token.setOuvrant(openedEnsemble = not openedEnsemble)
				if openedEnsemble then info.messages.push "#{token.delimeterType} ne peut pas ouvrir un ensemble"
				else info.messages.push "#{token.delimeterType} ne peut pas fermer un ensemble"
				return null
		if openedEnsemble
			info.messages.push "Ensemble ouvert mais pas refermé"
			return null

		gauche = undefined
		droite = tokens.shift()
		stack = []
		while gauche? or droite?
			switch
				when ((droite?.opType is "-") or (droite?.opType is "+")) and not gauche?.acceptOperOnRight()
					# L'opérateur binaire - est transformé en opérateur unaire -
					# Si c'est un +, il est ignoré
					if droite?.opType is "-" then stack.push gauche = droite.setOpposite()
					droite = tokens.shift()
				when gauche?.acceptOperOnRight() and droite?.acceptOperOnLeft()
					# Ajout d'un * sous-entendu
					stack.push new TokenOperator("*"), gauche = droite
					droite = tokens.shift()
				when gauche?.operateOnRight() and not droite?.acceptOperOnLeft()
					# le token de gauche essaie d'opérer sur un item qui ne l'accepte pas
					# Il y a donc une erreur
					if typeof droite is "undefined" then info.messages.push "#{gauche} en fin de chaîne"
					else info.messages.push "#{gauche} à gauche de #{droite}"
					return null
				when not gauche?.acceptOperOnRight() and droite?.operateOnLeft()
					# le token de droite essaie d'opérer sur un item qui ne l'accepte pas
					# Il y a donc une erreur
					if typeof gauche is "undefined" then info.messages.push "#{droite} en début de chaîne"
					info.messages.push "#{droite} à droite de #{gauche}"
					return null
				else
					# Aucune erreur n'a été détectée
					gauche = droite
					if droite? then stack.push droite
					droite = tokens.shift()
		stack
	buildReversePolishNotation: (tokens) ->
		rpn = []
		stack = []
		for token in tokens
			switch
				when token instanceof TokenNumber then rpn.push token
				when token instanceof TokenVariable then rpn.push token
				when token instanceof TokenFunction then stack.push token
				when token instanceof TokenEnsembleDelimiter
					if token.ouvrant
						# Le token est chargé simultanément dans les deux piles
						stack.push token
						rpn.push token
					else
						# On dépile à la recherche de l'ouvrant
						# qui existe forcément
						rpn.push depile while (depile = stack.pop()) and not (depile instanceof TokenEnsembleDelimiter)
						rpn.push token
				when token instanceof TokenParenthesis
					if token.isOpeningParenthesis() then stack.push token
					else
						# On dépile jusqu'à rencontrer (
						# ou vider la pile - ce qui constituerait une erreur)
						# ou rencontrer un délimiteur d'ensemble
						rpn.push depile while (depile = stack.pop()) and not (depile instanceof TokenParenthesis) and not (depile instanceof TokenEnsembleDelimiter)
						# Si le dernier élément dépilé est un délimiteur d'ensemble
						# Il faut le rempiler
						if depile instanceof TokenEnsembleDelimiter then stack.push depile
				else
					# Il s'agit d'un opérateur
					rpn.push(depile) while (depile = stack.pop()) and (depile.getPriority() >= token.getPriority())
					if depile then stack.push depile
					stack.push token
		# Enfin on vide la pile restante qui ne contient plus de délimiteurs d'ensembles
		while depile = stack.pop()
			if not (depile instanceof TokenParenthesis) then rpn.push depile
		rpn
	buildObject: (rpn) ->
		stack = []
		stack.push token.execute(stack) while token = rpn.shift()
		stack
}

#----------Parser---------
class ParseInfo
	object: null
	tex: "?"
	valid: true
	expression: ""
	type:""
	constructor: (value,params) ->
		@simplificationList = [] #liste des flags de simplification
		@messages = [] # messages d'erreur
		@context = "" # A modifier : mise dans un context particulier pour certaines simplifications
		# config
		@config = mergeObj({ developp:false, simplify:true, type:"number", toLowerCase:false, alias:false }, params)
		@type = @config.type
		if typeof value is "string"
			@expression = value
			if @config.toLowerCase then value = value.toLowerCase()
			SymbolManager.setAlias(@config.alias)
			value = ParseManager.parse(value, @config.type, @)
			if value is false
				# Le parse est invalid
				@setInvalid()
				# Pour éviter une erreur, on renvoie tout de même un objet
				switch
					when @config.type is "number" then value = new RealNumber()
					when @config.type is "ensemble" then value = new Ensemble()
					when @config.type is "equation" then value = new Equation(null,null)
					else value = new MObject()
		if value instanceof MObject
			# Cas où on a fourni directement un objet pour suivi de simplifications
			@object = value
			@tex = value.tex(@config)
			if @config.developp and (dvp = @object.developp(@)) then @object = dvp
			if @config.simplify and (simp = @object.simplify(@)) then @object = simp
	# Suivi des simplifications
	# Markers pour les nombres
	# ADD_SIMPLE, MULT_SIMPLE, ADD_REGROUPEMENT, EXPOSANT_UN, EXPOSANT_ZERO, PUISSANCE, RATION_REDUCTION
	# MULT_SYMBOLE, DIVISION_EXACTE, APPROX, RACINE, EXPOSANT_DEVELOPP, DISTRIBUTION
	# Contexte : |IN_RADICAL
	# Markers pour les ensembles
	# }_inattendu
	set: (flag) -> @simplificationList.push(flag+@context)
	setInvalid: () ->
		@valid = false
		@
	setContext: (context) ->
		@context = "|"+context
		@
	clearContext: () ->
		@context = ""
		@
	forme: (authorized) ->
		# Si certaine simplification sont présentes, ont refuse directement
		# Si l'argument est un tableau, on peut renvoyer un tableau avec les réponses adaptées
		if isArray(authorized) then return (@forme author for author in authorized)
		@simplificationList.sort()
		# Attention, les tableaux doivent être triés pour l'utilisation de array_intersect
		if arrayIntersect(@simplificationList, ["ADD_SIMPLE", "DIVISION_EXACTE", "MULT_SIMPLE"]).length>0 then return false
		# S'il y a développement d'un exposant alors automatiquement il y aura des regroupement
		if not authorized?.distribution and (authorized isnt "DISTRIBUTION") and arrayIntersect(@simplificationList, ["DISTRIBUTION", "ADD_REGROUPEMENT", "EXPOSANT_DEVELOPP", "PUISSANCE"]).length>0 then return false
		if not authorized?.racine and (authorized isnt "RACINE") and ("RACINE" in @simplificationList) then return false
		if not authorized?.fraction and (authorized isnt "FRACTION") and ("RATIO_REDUCTION" in @simplificationList) then return false
		true

