
#----------Parser---------
class @Parser
	Tokens: null
	globalRegex: null
	object: null
	tex: "?"
	invalid: false
	@parse: (expression,params) ->
		p = new Parser expression,params
		return p.object
	constructor: (value,params) ->
		@simplificationList = [] #liste des flags de simplification
		@messages = [] # messages d'erreur
		@context = "" # A modifier : mise dans un context particulier pour certaines simplifications
		# config
		@config = mergeObj({ developp:false, simplify:true, type:"number", toLowercase:false }, params)
		if typeof value is "string" then value = @parse value
		if value instanceof MObject
			# Cas où on a fourni directement un objet pour suivi de simplifications
			@object = value
			@tex = value.tex()
			if @config.developp and (dvp = @object.developp(@)) then @object = dvp
			if @config.simplify and (simp = @object.simplify(@)) then @object = simp
	check_type: (value,type) ->
		switch type
			when "ensemble" then return (value instanceof EnsembleObject)
			when "number" then return (value instanceof NumberObject)
			else return false
	parse: (expression) ->
		@str = expression
		@initParse()
		# Les élèves ont le réflexe d'utiliser la touche ² présente sur les claviers
		expression = expression.replace?("²", "^2 ")
		expression = expression.replace?("³", "^3 ")
		expression = expression.replace?("⁴", "^4 ")
		if @config.toLowercase then expression = expression.toLowerCase()
		#try
		matchList = expression.match(@globalRegex)
		if matchList?
			rpn = @buildReversePolishNotation @correction matchList.map @createToken
			output = @buildObject(rpn).pop()
		#catch e
		#	console.log e.message
		#	@messages.push e.message
		if not @check_type(output,@config.type)
			switch
				when @config.default is "NaN" then output = new RealNumber()
				when @config.default is "Nul" then output = new RealNumber(0)
				when @config.default is "empty" then output = new Ensemble()
				when @config.default is "reels" then output = (new Ensemble()).inverse()
				when @config.type is "number" then output = new NumberObject()
				when @config.type is "ensemble" then output = new Ensemble()
				else output = new MObject()
		output
	initParse: ->
		# Pour éviter d'alourdir le constructor dans le cas où la classe ne servirait à aucun parse
		# Initialisation du parser
		if @Tokens is null then @Tokens = [TokenNumber, TokenParenthesis, TokenOperator, TokenFunction, TokenVariable, TokenEnsembleDelimiter]
		if @globalRegex is null then @globalRegex = new RegExp ( "("+Token.getRegex()+")" for Token in @Tokens ).join("|"), "gi"
	createToken: (tokenString) =>
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
	# Suivi des simplifications
	# Markers pour les nombres
	# ADD_SIMPLE, MULT_SIMPLE, ADD_REGROUPEMENT, EXPOSANT_UN, EXPOSANT_ZERO, PUISSANCE, RATION_REDUCTION
	# MULT_SYMBOLE, DIVISION_EXACTE, APPROX, RACINE, EXPOSANT_DEVELOPP, DISTRIBUTION
	# Contexte : |IN_RADICAL
	# Markers pour les ensembles
	# }_inattendu
	set: (flag) -> @simplificationList.push(flag+@context)
	setInvalid: () ->
		@invalid = true
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
		if arrayIntersect(@simplificationList, ["ADD_REGROUPEMENT", "ADD_SIMPLE", "DISTRIBUTION", "DIVISION_EXACTE", "EXPOSANT_DEVELOPP", "MULT_SIMPLE", "PUISSANCE"]).length>0 then return false
		if not authorized?.racine and (authorized isnt "RACINE") and ("RACINE" in @simplificationList) then return false
		if not authorized?.fraction and (authorized isnt "FRACTION") and ("RATIO_REDUCTION" in @simplificationList) then return false
		true

