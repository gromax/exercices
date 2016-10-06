# Objet permettant de fabriquer les objets mathématiques depuis l'extérieur
@mM = {
	alea: {
		# Ensemble des objets produits aléatoirement
		poly : (params) ->
			config = Tools.merge {
				variable:"x" 	# variable du polynome
				degre:0 		# impose le degré ou sinon {min, max}
				monome:false 	# simple monome
				degreMin : 0 	# donne un degré minimum
				degreMax : 4 	# donne un degré max
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
				if i isnt 0 then coeff = new Monome( coeff, {name:config.variable, power:i})
				coeffs.push coeff
			if coeffs.length is 1 then coeffs.pop()
			else new PlusNumber(coeffs.reverse()...)
		number : (params) ->
			# Si params.values est indéfini, on envoie directement params à Proba.alea
			unless params?.values? then return new RealNumber Proba.alea(params)
			config = Tools.merge {
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
	}
	exec: (arr,params) ->
		# execute le tableau comme une pile inversée
		config = Tools.merge {
			simplify: false
		}, params

		arr.reverse()
		pile=[]
		if not Tools.typeIsArray(arr) then return new RealNumber()
		while arr.length>0
			arg = arr.pop()
			switch
				when arg instanceof NumberObject then pile.push arg
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
				when arg in ["x","y","t","i","pi","e","∞","#"] then pile.push SymbolNumber.makeSymbol(arg)
				when (typeof arg is "string") and (FunctionNumber.functions[arg]?) then pile.push(new FunctionNumber(arg,pile.pop()))
				when typeof arg is "number" then pile.push(new RealNumber(arg))
		if pile.length is 0 then return new RealNumber()
		out = pile.pop()
		if config.simplify then return out.simplify()
		out
	parse: (expression,params) -> (new Parser expression,params).object
}
