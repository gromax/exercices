
DECIMAL_SEPARATOR = ','
DECIMAL_MAX_PRECISION = 10
SOLVE_MAX_PRECISION = 14
ERROR_MIN = 0.00000000000001

#----------Tokens---------
class Token
	getPriority: -> 0
	acceptOperOnLeft: -> false
	operateOnLeft: -> false
	acceptOperOnRight: -> false
	operateOnRight: -> false
	execute: (stack) -> new MObject()
class TokenNumber extends Token
	constructor: (str) ->
		switch
			when typeof str is "string"
				# Pour le suivi, on doit savoir la précision donnée par l'utilisateur :
				# 3,5 n'est pas la même chose que 3,50
				# @p représentera le nombre de chiffres après la virgule
				str = str.replace /\,/, "."
				if (i = str.indexOf("%"))>0
					val = Number str.substring(0,i)
					val = val/100
					@percent = true
					@value = Number(val.toFixed(DECIMAL_MAX_PRECISION))
				else @value = Number(Number(str).toFixed(DECIMAL_MAX_PRECISION))
			when typeof str is "number" then @value = str
			else @value = NaN
	@getRegex: -> '\\d+[.,]?\\d*(E-?\\d+)?%?'
	acceptOperOnLeft: -> true
	acceptOperOnRight: -> true
	execute: (stack) ->
		out = new RealNumber @value
		if @percent then out.setPercent true
		out
class TokenVariable extends Token
	constructor: (@name) ->
	@getRegex: -> "[#π∅ℝ∞a-zA-Z_\\x7f-\\xff][a-zA-Z0-9_\\x7f-\\xff]*"
	acceptOperOnLeft: -> true
	acceptOperOnRight: -> true
	execute: (stack) -> SymbolNumber.makeSymbol @name
class TokenOperator extends Token
	operand1: null
	operand2: null
	constructor: (@opType) ->
	@getRegex: -> "[\\+\\-\\/\\^;=∪∩]"
	setOpposite: ->
		@opType = "0-"
		@
	getPriority: ->
		switch
			when @opType is "^" then 9
			when @opType is "0-" then 8
			when (@opType is "*") or (@opType is "/") then 7
			when (@opType is "+") or (@opType is "-") then 6
			when @opType is "∩" then 5
			when @opType is "∪" then 4
			else 1
	acceptOperOnLeft: -> @opType is "0-"
	operateOnLeft: -> @opType isnt "0-"
	operateOnRight: -> true
	execute: (stack) ->
		if @opType is "0-"
			stack.pop()?.opposite?()
		else
			@operand2 = stack.pop()
			@operand1 = stack.pop()
			switch
				when @opType is "+" then PlusNumber.makePlus( [@operand1, @operand2] )
				when @opType is "-" then PlusNumber.makePlus( [@operand1, @operand2?.opposite?()] )
				when @opType is "*" then MultiplyNumber.makeMult( [@operand1, @operand2] )
				when @opType is "/" then MultiplyNumber.makeDiv( @operand1, @operand2 )
				when @opType is "^" then PowerNumber.make( @operand1, @operand2 )
				when @opType is ";" then new Collection(";", [@operand1, @operand2] )
				when @opType is "=" then new Collection("=", [@operand1, @operand2] )
				when @opType is "∪" then new Union( @operand1, @operand2 )
				when @opType is "∩" then new Intersection( @operand1, @operand2 )
				else new RealNumber()
class TokenFunction extends Token
	operand: null
	# Debug : Le name semble limité deux fois de suite
	constructor: (@name) ->
	@getRegex: -> "sqrt|racine|cos|sin"
	getPriority: -> 10
	acceptOperOnLeft: -> true
	operateOnRight: -> true
	execute: (stack) -> FunctionNumber.make(@name, stack.pop())
class TokenParenthesis extends Token
	constructor: (token) ->
		@type = token
	@getRegex: -> "[\\(\\)]"
	acceptOperOnLeft: -> @type is "("
	acceptOperOnRight: -> @type is ")"
	isOpeningParenthesis: -> @type is "("
	isClosingParenthesis: -> @type is ")"
class TokenEnsembleDelimiter extends Token
	constructor: (@delimiterType) ->
		@ouvrant = false
	@getRegex: -> "[\\[\\]\\{\\}]"
	acceptOperOnLeft: -> @ouvrant
	acceptOperOnRight: -> not @ouvrant
	setOuvrant: (newValue) ->
		@ouvrant = newValue
		@
	execute: (stack) ->
		if not @ouvrant
			ops = []
			while (depile = stack.pop()) and not (depile instanceof TokenEnsembleDelimiter)
				if depile instanceof Collection
					collect = depile.getOperands()
					ops.unshift op while (op=collect.pop())
				else ops.unshift depile
			EnsembleObject.make(depile?.delimiterType,ops,@delimiterType)
		else @
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
		@config = Tools.merge({ developp:false, simplify:true, type:"number" }, params)
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
	parse: (expression,params) ->
		@str = expression
		@initParse()
		# Les élèves ont le réflexe d'utiliser la touche ² présente sur les claviers
		expression = expression.replace?("²", "^2")
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
		if typeIsArray(authorized) then return (@forme author for author in authorized)
		@simplificationList.sort()
		# Attention, les tableaux doivent être triés pour l'utilisation de array_intersect
		if arrayIntersect(@simplificationList, ["ADD_REGROUPEMENT", "ADD_SIMPLE", "DISTRIBUTION", "DIVISION_EXACTE", "EXPOSANT_DEVELOPP", "MULT_SIMPLE", "PUISSANCE"]).length>0 then return false
		if not authorized?.racine and (authorized isnt "RACINE") and ("RACINE" in @simplificationList) then return false
		if not authorized?.fraction and (authorized isnt "FRACTION") and ("RATIO_REDUCTION" in @simplificationList) then return false
		true
