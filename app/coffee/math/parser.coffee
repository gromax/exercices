
ParseManager = {
	Tokens: null
	globalRegex: null
	initParse: ->
		# Pour éviter d'alourdir le constructor dans le cas où la classe ne servirait à aucun parse
		# Initialisation du parser
		if @Tokens is null then @Tokens = [TokenNumber, TokenParenthesis, TokenOperator, TokenFunction, TokenVariable, TokenEnsembleDelimiter]
		if @globalRegex is null then @globalRegex = new RegExp ( "("+Token.getRegex()+")" for Token in @Tokens ).join("|"), "gi"
	parse: (expression) ->
		@initParse()
		# Les élèves ont le réflexe d'utiliser la touche ² présente sur les claviers
		expression = expression.replace?("²", "^2 ")
		expression = expression.replace?("³", "^3 ")
		expression = expression.replace?("⁴", "^4 ")
		matchList = expression.match(@globalRegex)
		if matchList?
			rpn = @buildReversePolishNotation @correction matchList.map @createToken, @
			output = @buildObject(rpn).pop()
		else output = null
		output
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
	createToken: (tokenString) ->
		# tous les tokens doivent être reconnus car les autres sont exclus par le tri effectué sur la chaîne
		for Token in @Tokens
			regex = new RegExp(Token.getRegex(),'i')
			if regex.test(tokenString) then return new Token(tokenString)
	correction: (tokens) ->
		# Gestion des délimiters d'ensembles
		openedEnsemble = false
		for token in tokens
			if token instanceof TokenEnsembleDelimiter then token.setOuvrant(openedEnsemble = not openedEnsemble)
		if openedEnsemble then tokens.push (new TokenEnsembleDelimiter())

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
					# Il faut supprimer le token de gauche
					stack.pop()
					gauche = droite
					if droite? then stack.push droite
					droite = tokens.shift()
				when not gauche?.acceptOperOnRight() and droite?.operateOnLeft()
					# le token de droite essaie d'opérer sur un item qui ne l'accepte pas
					# Il faut supprimer le token de droite
					# Pour cela, il suffit de l'ignorer et de passer au suivant
					droite = tokens.shift()
				else
					# Aucune erreur n'a été détectée
					gauche = droite
					if droite? then stack.push droite
					droite = tokens.shift()
		stack
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
		@config = mergeObj({ developp:false, simplify:true, type:"number", toLowercase:false }, params)
		@type = @config.type
		if typeof value is "string"
			@expression = value
			if @config.toLowercase then value = value.toLowerCase()
			value = @check_type ParseManager.parse(value), @config.type, @config.default
		if value instanceof MObject
			# Cas où on a fourni directement un objet pour suivi de simplifications
			@object = value
			@tex = value.tex(@config)
			if @config.developp and (dvp = @object.developp(@)) then @object = dvp
			if @config.simplify and (simp = @object.simplify(@)) then @object = simp
	check_type: (value,type,def) ->
		switch
			when (type is "ensemble") and (value instanceof EnsembleObject) then return value
			when (type is "number") and (value instanceof NumberObject) then return value
			when (type is "equation") and (value instanceof Equation) then return value
			when (type is "equation") and (value instanceof NumberObject)
				@setInvalid()
				return new Equation(value,null)
			when type is "equation"
				@setInvalid()
				return new Equation(null,null)
			when def is "NaN"
				@setInvalid()
				return new RealNumber()
			when def is "Nul"
				@setInvalid()
				return new RealNumber(0)
			when def is "empty"
				@setInvalid()
				return new Ensemble()
			when def is "reels"
				@setInvalid()
				return (new Ensemble()).inverse()
			when type is "number"
				@setInvalid()
				return new NumberObject()
			when type is "ensemble"
				@setInvalid()
				return new Ensemble()
			else
				@setInvalid()
				return new MObject()
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
		if arrayIntersect(@simplificationList, ["ADD_REGROUPEMENT", "ADD_SIMPLE", "DIVISION_EXACTE", "EXPOSANT_DEVELOPP", "MULT_SIMPLE", "PUISSANCE"]).length>0 then return false
		if not authorized?.distribution and (authorized isnt "DISTRIBUTION") and ("DISTRIBUTION" in @simplificationList) then return false
		if not authorized?.racine and (authorized isnt "RACINE") and ("RACINE" in @simplificationList) then return false
		if not authorized?.fraction and (authorized isnt "FRACTION") and ("RATIO_REDUCTION" in @simplificationList) then return false
		true

