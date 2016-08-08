
# Classe de fonctions servant à manipuler les objets de la classe math
class @NumberManager
	@parse: (expression,params) -> Parser.parse expression, Tools.merge({type:NumberObject}, params)
	@makeNumber: (value,params) ->
		# On génère un NumberObject
		# params sert surtout au parsing
		switch
			when typeof value is "number" then return new RealNumber(value)
			when typeof value is "string" then return Parser.parse value, Tools.merge({type:"number"}, params)
			when value instanceof NumberObject then return value
			when typeof value is "object"
				if typeof value.numerator is "number" then return new RationalNumber(value.numerator, value.denominator)
				if typeof value.reel is "number" then return new ComplexeNumber(value.reel, value.imaginaire)
				return new RealNumber()
			else new RealNumber()
	@makeNaN: -> new RealNumber()
	@makeProduct: (ops) -> MultiplyNumber.makeMult ops
	@makeSum: (ops) -> PlusNumber.makePlus ops
	@makeSymbol: (symbolName) -> SymbolNumber.makeSymbol(symbolName)
	@makeI: -> new ComplexeNumber(0,1)
	@pi: -> SymbolNumber.pi()
	@setSymbolValue: (symbolName, value) ->
		if not(value instanceof NumberObject) then value = NumberManager.makeNumber(value)
		SymbolNumber.setSymbolValue(symbolName, value)
	@compare: (a, b) ->
		if not(a instanceof NumberObject) then a = NumberManager.makeNumber(a)
		if not(b instanceof NumberObject) then b = NumberManager.makeNumber(b)
		# Retourne false si NaN ou complexe
		# +1 si a est supérieur
		# 0 pour une égalité
		# -1 pour b supérieur
		ecart = a.toClone().am(b,true);
		if ecart.isNul() then return 0			# Peut fonctionner pour un complexe
		if ecart.isPositive() then return 1		# Fonctionne pour +infini
		if ecart.isNegative() then return -1	# Fonctionne pour -infini
		if (a instanceof InftyNumber) and (b instanceof InftyNumber)
			# S'ils étaient de signes opposés, on aurait conclut avec les cas précédents
			# On considère qu'étant de même signe ils sont égaux
			return 0
		false # Un complexe renvoie false, de même qu'un réel de value = NaN
		# À noter qu'un nombre peut renvoyer faux aussi bien à positif qu'à négatif, s'il est NaN ou écart complexe
	@ecart: (a, b) ->
		if not(a instanceof NumberObject) then a = NumberManager.makeNumber(a)
		if not(b instanceof NumberObject) then b = NumberManager.makeNumber(b)
		a.floatify().am(b.floatify(),true)
	@distance: (a, b) ->
		if not(a instanceof NumberObject) then a = NumberManager.makeNumber(a)
		if not(b instanceof NumberObject) then b = NumberManager.makeNumber(b)
		d = a.toClone().am(b,true).floatify().abs().toNumber()
		if a.getModulo() isnt false then modA = a.getModulo().floatify().abs().toNumber()
		else modA=-1
		if b.getModulo() isnt false then modB = b.getModulo().floatify().abs().toNumber()
		else modB=-1
		# Je ne prends en compte qu'un seul des modulo
		modulo = Math.max(modA,modB)
		if modulo>0
			d-= modulo while modulo<=d
		if d<ERROR_MIN then d = 0
		d
	@equal: (a, b) ->
		if not(a instanceof NumberObject) then a = NumberManager.makeNumber(a)
		if not(b instanceof NumberObject) then b = NumberManager.makeNumber(b)
		a.floatify().am(b.floatify(),true).isNul()
	@erreur: (good, answer) ->
		if not(good instanceof NumberObject) then good = NumberManager.makeNumber(good)
		if not(answer instanceof  NumberObject) then answer = NumberManager.makeNumber(answer)
		moduloError=false
		if modulo = good.getModulo()
			floatModulo = Math.abs modulo.toNumber()
			answerModuloObject = answer.modulo()
			if (answerModuloObject.modulo isnt false)
				moduloError = (answerModuloObject.modulo.toClone().am(modulo,true).floatify().abs().toNumber() > ERROR_MIN)
				answer = answerModuloObject.base
			else moduloError = true
			if moduloError then moduloError = modulo.tex()
		else floatModulo = 0
		ecart = good.toClone().am(answer,true).simplify().floatify().abs().toNumber()
		if floatModulo>0
			ecart -= floatModulo while floatModulo<=ecart
		if ecart<ERROR_MIN then ecart = 0
		if answer instanceof RealNumber
			# Dans ce cas, l'utilisateur donne une valeur numérique
			# Cette valeur peut donc être exacte, ou approximative
			# On cherche l'ordre de grandeur de la justesse de la réponse.
			# On souhaite aussi savoir s'il s'agit d'une troncature au lieu d'une approx
			# On souhaite aussi connaître le nombre de décimales de la réponse de l'utilisateur (p_user)
			if ecart is 0 then return { exact:true, float:true, moduloError:moduloError, p_user:answer.precision() }
			else
				#ordre_exp = Math.ceil(Math.log(ecart)/Math.LN10)
				if (answer.precision()>=2*ecart)
					# L'erreur est plus petite que le degré de précision donné par l'utilisateur
					# C'est ici qu'éventuellement on parlera de troncature
					return { exact:false, float:true, approx_ok:true, ecart:ecart, moduloError:moduloError, p_user:answer.precision() }
				else return { exact:false, float:true, approx_ok:false, ecart:ecart, moduloError:moduloError, p_user:answer.precision() }
		# L'utilisateur donne une formule. On attend donc une valeur exacte.
		{ exact: (ecart is 0), float:false, moduloError:moduloError }
	@verificationForme: (answer, options) ->
		switch
			when answer instanceof RealNumber
				return "réel" in options
			when answer instanceof RationalNumber
				return ("fraction" in options) or ("fraction_réduite" in options) and not answer.testReduction()
			when answer instanceof RadicalNumber
				return "racine" in options
		false
	@tri: (users,goods) ->
		# On donne un tableau de réponses utilisateur et un tableau de bonnes réponses
		# On cherche à les associer 2 à 2 et à renvoyer le tableau des bonnes réponses
		# trier dans le bon ordre relativement à users
		# On organise les goods et on en profite pour détecter un modulo
		modulosToSearch = false
		goodsObj = []
		for good, i in goods
			modulosToSearch = modulosToSearch or (good.getModulo() isnt false)
			goodsObj.push {value: @makeNumber(good), rank:i, d:[]}
		# On organise les users et en présence d'un modulo sur les goods
		# on détecte les modulos sur les users
		usersObj = []
		for user, i in users
			user = @makeNumber(user)
			if modulosToSearch
				moduloObj = user.modulo()
				if moduloObj.modulo isnt false then user = moduloObj.base
			usersObj.push {value:user, rank:i, d:[]}
		paired_users = []
		maxIter = usersObj.length*(usersObj.length+1)/2
		# Évite une éventuelle boucle infinie. Dans tous les cas, le nombre d'iter
		# ne devrait pas dépasser n(n+1)/2
		while (usersObj.length>0) and (goodsObj.length>0) and (maxIter>0)
			maxIter--
			user = usersObj.shift()
			closestGood = NumberManager.helper_searchClosest(user,goodsObj)
			closestUser = NumberManager.helper_searchClosest(closestGood,usersObj,user)
			if closestUser.rank is user.rank
				# On a trouvé une paire
				user.closest = closestGood.value
				paired_users.push(user)
			else
				# La paire n'est pas bonne
				# On remet user à la suite
				usersObj.push(user)
				goodsObj.push(closestGood)
		# Il pourrait rester des users en souffrance
		# Soit faute de good, soit faute d'un dysfonctionnement
		paired_users.push usersObj.pop() while usersObj.length>0
		paired_users.sort (a,b) ->
			if a.rank<b.rank then -1
			else 1
		output = { closests:(us.closest for us in paired_users), lefts:(goodO.value for goodO in goodsObj)}
	@searchClosest: (value, liste) ->
		unless value instanceof NumberObject then value=@makeNumber value
		tab = []
		for it,i in liste
			unless it instanceof NumberObject then it=@makeNumber it
			tab.push { value:it, rank:i }
		closest = @helper_searchClosest { value:value, d:[]}, tab
		closest.value
	@helper_searchClosest: (obj,tab,testOut) ->
		# Helper pour la fonction de tri
		# obj est de la forme { valeue:NumberObject, d:array, }
		# tab est un array de { value:NumberObject, rank:number }
		# out pointe sur l'objet le plus proche trouvé à un point du programme
		if tab.length is 0 then return testOut
		if typeof testOut is "undefined"
			out = tab[0]
			indice = 0
		else
			out = testOut
			indice = -1
		if typeof obj.d[out.rank] is "undefined" then obj.d[out.rank] = @distance obj.value, out.value
		for oTab,i in tab
			if typeof obj.d[oTab.rank] is "undefined" then obj.d[oTab.rank] = @distance obj.value, oTab.value
			if (obj.d[oTab.rank]<obj.d[out.rank]) or isNaN(obj.d[out.rank]) and not isNaN(obj.d[oTab.rank])
				out = oTab
				indice = i
		if typeof testOut is "undefined" then tab.splice(indice,1)
		out
	@aleaPoly: (degre,variable="x") ->
		coeffs = (Proba.aleaEntreBornes(-10,10) for i in [1..degre])
		dominantCoeff = Proba.aleaEntreBornes(1,10)*Proba.aleaSign()
		variable=@makeSymbol(variable)
		output = new RealNumber dominantCoeff
		output = output.md(variable, false).am(@makeNumber coeff,false) for coeff in coeffs
		output.simplify()
