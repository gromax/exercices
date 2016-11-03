# Objet permettant de fabriquer les objets mathématiques depuis l'extérieur
@mM = {
	alea: {
		# Ensemble des objets produits aléatoirement
		poly : (params) ->
			config = mergeObj {
				variable:"x" 	# variable du polynome
				degre:0 		# impose le degré ou sinon {min, max}
				monome:false 	# simple monome
				coeffDom: null # Permet de fixer le numeréteur du degré dominant
				values:1		# numérateurs possibles
				denominators : null	# null-> entiers, nombre-> tous le même, tableau-> valeurs possibles, { min, max } -> intervalle de valeurs
			}, params
			degre = Proba.alea config.degre
			if degre<0 then degre =0
			if config.monome then degres = [degre] else degres = [0..degre]
			coeffs = []
			for i in degres
				coeff = if i is degre and (config.coeffDom isnt null) then @number config.coeffDom
				else @number {values:config.values, denominator:config.denominators}
				if not coeff.isNul()
					if i isnt 0 then coeff = new Monome( coeff, {name:config.variable, power:i})
					coeffs.push coeff
			if coeffs.length is 1 then coeffs.pop()
			else new PlusNumber(coeffs.reverse()...)
		number : (params) ->
			# Si params.values est indéfini, on envoie directement params à Proba.alea
			unless params?.values? then return new RealNumber Proba.alea(params)
			config = mergeObj {
				sign: false 		# produit un signe aléatoire
				denominator : null 	# null-> entier, nombre-> impose une valeur, tableau-> valeurs possibles, { min, max } -> intervalle de valeurs
			}, params
			num = Proba.alea config.values
			if config.denominator?
				deno = Proba.alea config.denominator
				if deno is 0 then deno = 1
				out = (new RationalNumber num,deno).simplify()
			else out = new RealNumber num
			if (config.sign is true) and (Math.random()<.5) then out.opposite()
			out
		real: (params) ->
			# Même principe que précédent mais avec simple retour d'un nombre
			unless params?.values? then return Proba.alea(params)
			config = mergeObj {
				sign: false 		# produit un signe aléatoire
				denominator : null 	# null-> entier, nombre-> impose une valeur, tableau-> valeurs possibles, { min, max } -> intervalle de valeurs
			}, params
			num = Proba.alea config.values
			if config.denominator?
				deno = Proba.alea config.denominator
				if deno is 0 then deno = 1
				out = num/deno
			else out = num
			if (config.sign is true) and (Math.random()<.5) then out *= -1
			out
		dice: (up,down) ->
			# renvoie vrai ou faux pour un alea à la proba up/down
			Math.random()*down < up
		in: (arr) -> Proba.aleaIn arr
		vector: (params) ->
			config = mergeObj { axes:["x", "y"], def:{}, name:"?", values:[{min:-10, max:10}] }, params
			coords = { x:null, y:null, z:null }
			# on crée le point avant de s'assurer qu'il vérifie bien les conditions
			# tryLeft limite le nombre de boucles pour éviter d'entrer dans une boucle infinie
			# ok permet d'arrêter quand les conditions sont obtenues
			# force permet d'essayer dans un premier temps les valeurs def
			tryLeft = 10
			ok = false
			force = false
			while (ok is false) and (tryLeft>0)
				tryLeft -= 1
				for axe,i in config.axes
					if i<config.values.length then values = config.values[i]
					else values = config.values[0]
					if (typeof config.def[axe+config.name] is "undefined") or force
						coords[axe] = mM.alea.number values
					else
						coords[axe] = mM.toNumber config.def[axe+config.name]
				# On va tester pour voir si les coordonnées obtenues répondent bien aux conditions
				ok = true
				if isArray(config.forbidden)
					for item in config.forbidden
						switch
							when item instanceof Vector then ok = ok and not(item.sameAs coords)
							when item?.axe? then ok = ok and not(item.coords.sameAs coords, item.axe)
							when isArray(item?.aligned) and (item.aligned.length is 2) then ok = ok and not(item.aligned[0].aligned?(item.aligned[1], coords))
				force = true
			return new Vector config.name, coords
	}
	test: {
		isFloat: (number) ->
			nO = mM.toNumber(number)
			unless nO instanceof RealNumber then return false
			out = nO.float()
			if Number.isNaN(out) then return false
			out
	}
	trigo:{
		degToRad: (value) ->
			switch
				when isArray(value) then return @degToRad mM.exec value
				when value instanceof NumberObject then return value.toClone().md(new RealNumber(180),true).md(SymbolNumber.makeSymbol("pi"),false).simplify()
				when typeof value is "number" then return value * Math.PI() / 180
				else return NaN
		radToDeg: (value) ->
			switch
				when isArray(value) then return @radToDeg mM.exec value
				when value instanceof NumberObject then return value.toClone().md(new RealNumber(180),false).md(SymbolNumber.makeSymbol("pi"),true).simplify()
				when typeof value is "number" then return value / Math.PI() * 180
				else return NaN
		angles: -> Trigo.anglesConnus()
		principale: (value,symbols) ->
			value = mM.toNumber value
			nPi = value.floatify(symbols).float()/Math.PI
			tours = Math.round(nPi/2)*2
			output = value.toClone().am (new RealNumber tours).md(SymbolNumber.pi(),false), true
			if nPi-tours is -1 then output.opposite()
			output.simplify()
		complexe: (module, argument) ->
			# l'argument est un angle en degrés donné comme un float
			module = mM.toNumber module
			Trigo.cos(argument).md(module,false).am(Trigo.sin(argument).md(module,false).md(new ComplexeNumber(0,1),false),false).simplify()
	}
	exec: (arr,params) ->
		# execute le tableau comme une pile inversée
		config = mergeObj {
			simplify: false
			developp: false
			modulo:false
			clone:true
		}, params

		arr.reverse()
		pile=[]
		if not isArray(arr) then return new RealNumber()
		while arr.length>0
			arg = arr.pop()
			switch
				when arg instanceof NumberObject
					if config.clone then pile.push arg.toClone()
					else pile.push arg
				when arg is "+"
					op2 = pile.pop()
					pile.push(new PlusNumber(pile.pop(),op2))
				when arg is "-"
					op2 = pile.pop()?.opposite?()
					pile.push(new PlusNumber(pile.pop(),op2))
				when arg is "*"
					op2 = pile.pop()
					pile.push(new MultiplyNumber(pile.pop(),op2))
				when arg is "/"
					op2 = pile.pop()
					pile.push(MultiplyNumber.makeDiv(pile.pop(),op2))
				when arg is "^"
					op2 = pile.pop()
					pile.push(new PowerNumber(pile.pop(),op2))
				when arg is "*-" then pile.push(pile.pop()?.opposite?())
				when arg is "conjugue" then pile.push(pile.pop()?.conjugue?())
				when arg is "^-1" then pile.push(pile.pop()?.inverse?())
				when arg is "union"
					op2 = pile.pop()
					op1 = pile.pop()
					pile.push(new Union(op1,op2))
				when arg is "intersection"
					op2 = pile.pop()
					op1 = pile.pop()
					pile.push(new Intersection(op1,op2))
				when arg is "modulo"
					op2 = pile.pop()
					pile.push(pile.pop()?.setModulo(op2))
				when arg in ["x","y","t","i","pi","#","e","∞"] then pile.push SymbolNumber.makeSymbol(arg)
				when (typeof arg is "string") and (FunctionNumber.functions[arg]?) then pile.push(new FunctionNumber(arg,pile.pop()))
				when typeof arg is "number" then pile.push(new RealNumber(arg))
				when (typeof arg is "string") and (m = arg.match /// ^symbol:([a-zA-Z_]+)$ ///i) then pile.push SymbolNumber.makeSymbol(m[1])
				when (typeof arg is "string") and (m = arg.match /// ^ensemble:([\[\]]+)([\[\]]+)$ ///i)
					op2 = pile.pop()
					op1 = pile.pop()
					pile.push (new Ensemble()).init(m[1] is "[", op1, m[2] is "]", op2)
		if pile.length is 0 then return new RealNumber()
		out = pile.pop()
		if config.simplify then out = out.simplify(null,config.developp)
		if config.modulo isnt false
			# On cherche à extraire un modulo
			unless typeof config.modulo is "string" then config.modulo = "modulo"
			decomposition = out.modulo(config.modulo)
			unless decomposition.modulo is false then out = decomposition.base.setModulo(decomposition.modulo)
		out
	parse: (expression,params) -> (new Parser expression,params).object
	toNumber: (value) ->
		switch
			when $.isNumeric( value ) then return new RealNumber(Number value)
			when (value is null) or (typeof value is "undefined") then return new RealNumber()
			when isArray value then return @exec value
			when value instanceof NumberObject then return value
			when typeof value is "object"
				if typeof value.numerator is "number"
					out = new RationalNumber(value.numerator, value.denominator)
					if value.simplify then out = out.simplify()
					return out
				if typeof value.reel is "number" then return new ComplexeNumber(value.reel, value.imaginaire)
				return new RealNumber()
			when value is "NaN" then return new RealNumber()
			when typeof value is "string" then return @parse value, {type:"number"}
			else new RealNumber()
	float: (value,params) ->
		# params contient les éventuels symboles utiles
		# params.decimals donne la precision
		decimals = params?.decimals
		switch
			when isArray value then (@float(item,params) for item in value)
			when isArray params then (@float(value,item) for item in params)
			when typeof value is "number" then value
			when value instanceof FloatNumber then value.float(decimals)
			when value instanceof NumberObject then value.floatify(params).float(decimals)
			when value instanceof Polynome then value.floatify(params).float(decimals)
			else NaN
	calc:(op1,op2,op)->
		Oop1 = @toNumber op1
		Oop2 = @toNumber op2
		switch op
			when "+" then return Oop1.am Oop2,false
			when "-" then return Oop1.am Oop2,true
			when "*" then return Oop1.md Oop2,false
			when "/" then return Oop1.md Oop2,true
			else return new RealNumber()
	vector: (name, coords) ->
		coords[key] = mM.toNumber(coords[key]) for key of coords
		new Vector name, coords
	droite: {
		par2pts: (A, B) ->
			if not((A instanceof Vector) and (B instanceof Vector)) then return new Droite2D(new RealNumber(0), new RealNumber(0), new RealNumber(0))
			uDir = B.toClone().am A, true
			a = uDir.y
			b = uDir.x.opposite()
			pt = A.toClone()
			c = pt.x.md(a,false).opposite().am(pt.y.md(b,false),true) # c=-ax-by
			return new Droite2D a,b,c
	}
	polynome: {
		make:(params) ->
			if typeof params is "string" then params = { expression:params }
			config = mergeObj {
				variable: "x"
			}, params
			switch
				when isArray(config.points)
					# Méthode lagrangian
					# points : liste de points de forme [{x:, y:}]
					# On vérifie que le tableau a bien le bon format
					indice=0
					while indice<config.points.length
						if (typeof config.points[indice].x is "undefined") or (typeof config.points[indice].y is "undefined") then config.points.splice(i,1)
						else
							config.points[indice].x = mM.toNumber(config.points[indice].x)
							config.points[indice].y = mM.toNumber(config.points[indice].y)
							indice++
					PolynomeMaker.lagrangian(config.points,config.variable)
				when isArray(config.roots)
					# on donne les racines
					if config.a? then a = mM.toNumber(a) else a = new RealNumber(1)
					indice = 0
					roots = ( mM.toNumber x for x in config.roots )
					PolynomeMaker.width_roots(a,roots,config.variable)
				when isArray(config.coeffs)
					# On donne les coeffs
					coeffs = ( mM.toNumber x for x in config.coeffs )
					PolynomeMaker.widthCoeffs(coeffs,config.variable)
				when config.expression? then PolynomeMaker.parse(config.expression, config.variable)
				else PolynomeMaker.invalid(config.variable)
		parse: (expression, variable="x") -> (new Parser expression,{type:"number"}).object?.toPolynome(variable)
		solve: {
			numeric: (poly,params) ->
				config = mergeObj {
					bornes: null	# {min: ,max:} sinon pris à l'infini
					decimals: 1
					y:0				# P(x) = y
				}, params
				poly.solve_numeric(config.bornes?.min, config.bornes?.max, config.decimals, config.y)
			exact: (poly,params) ->
				config = mergeObj {
					y:0				# P(x) = y
					imaginaire:false
				}, params
				y = mM.toNumber config.y
				poly.solveExact(y,config.imaginaire)
		}
	}
	suite: {
		geometrique: (params) ->
			config = mergeObj {
				nom: "u"
				raison: 1
				premierTerme: { valeur:1, rang:0 }
			}, params
			(new Suite(
				config.nom
				config.premierTerme.rang
				[ mM.toNumber(config.premierTerme.valeur) ]
				(x) -> @u_nMin[0].toClone().md(PowerNumber.make(@raison.toClone(),x.am(new RealNumber(@nMin),true)),false )
				(x) -> @raison.toClone().md(x,false)
			)).set("raison", mM.toNumber(config.raison))
		arithmetique: (params) ->
			config = mergeObj {
				nom: "u"
				raison: 0
				premierTerme: { valeur:0, rang:0 }
			}, params
			(new Suite(
				config.nom
				config.premierTerme.rang
				[ mM.toNumber config.premierTerme.valeur ]
				(x) -> @u_nMin[0].toClone().am(MultiplyNumber.makeMult([x.am(new RealNumber(@nMin),true),@raison.toClone()]),false )
				(x) -> x.toClone().am(@raison,false)
			)).set("raison",mM.toNumber(config.raison))
		arithmeticogeometrique: (params) ->
			config = mergeObj {
				nom: "u"
				q: 1
				r:0
				premierTerme: { valeur:0, rang:0 }
			}, params
			q = mM.toNumber(config.q)
			r = mM.toNumber(config.r)
			if q.floatify().float() is 1 then return (new Suite(
				config.nom
				config.premierTerme.rang
				[ mM.toNumber config.premierTerme.valeur ]
				(x) -> @u_nMin[0].toClone().am(MultiplyNumber.makeMult([x.am(new RealNumber(@nMin),true),@raison.toClone()]),false )
				(x) -> x.toClone().am(@raison,false)
			)).set("raison",r)
			h = r.toClone().md(q.toClone().am(new RealNumber(1),true),true)
			(new Suite(
				config.nom
				config.premierTerme.rang
				[ mM.toNumber config.premierTerme.valeur ]
				(x) -> @u_nMin[0].toClone().am(@h,false).md(PowerNumber.make(@q.toClone(),x.am(new RealNumber(@nMin),true)),false ).am(@h,true)
				(x) -> @q.toClone().md(x,false).am(@r,false)
			)).set("q",q).set("h",h).set("r",r)
	}
	isEnsemble: (value) -> value instanceof Ensemble
	ensemble: {
		vide: () -> new Ensemble()
		R: () -> (new Ensemble()).inverse()
		singleton: (value) ->
			v = mM.toNumber value
			(new Ensemble()).insertSingleton(v)
		intervalle:(ouvrant,val1,val2,fermant) ->
			v1 = mM.toNumber val1
			v2 = mM.toNumber val2
			(new Ensemble()).init((ouvrant is "[") or (ouvrant is true), v1, (fermant is "]") or (fermant is true), v2)
	}
	tri: (users,goods) ->
		goodsObj = ( { value: @toNumber(item), rank:i, d:[] } for item,i in goods )
		# on détecte les modulos sur les users
		usersObj = []
		for user, i in users
			user = @toNumber(user)
			moduloObj = user.modulo()
			if moduloObj.modulo isnt false then user = moduloObj.base
			usersObj.push { value:user, rank:i, d:[] }
		erreurManager.tri(usersObj,goodsObj)
	erreur:(good,userObject,symbols) ->
		# userObject est un NumberObject
		# good peut-être un tableau de proposition dont on cherchera la plus proche
		if isArray(good)
			closest = erreurManager.searchClosest( ( { value:@toNumber(item), rank:i } for item,i in good ), userObject )
			goodObject = if closest isnt null then good = closest.value else new RealNumber()
		else goodObject = @toNumber good
		erreurManager.main(goodObject,userObject,symbols)
}
