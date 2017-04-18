
PolynomeMaker = {
	invalid: (variable) -> (new Polynome(variable)).setInvalid()
	unite: (variable) -> new Polynome variable, [new RealNumber(1)]
	nul: (variable) -> new Polynome(variable)
	lagrangian: (liste, variable) ->
		# Génère le polynome passant par les points dont les couples yi = f(xi) sont spécifiés
		switch
			when liste.length is 0 then new Polynome(variable) # Polynôme identiquement nul
			when liste.length is 1 then new Polynome(variable, [liste[0].y])# Polynôme constant
			else
				arrPoly_0 = @lagrange_base(0,liste)
				for i in [1..liste.length-1]
					arrPoly_i = @lagrange_base(i,liste)
					arrPoly_0[j] = coeff.am arrPoly_i[j], false for coeff, j in arrPoly_0
				new Polynome(variable,arrPoly_0)
	lagrange_base: (index, liste) ->
		# on considère que la fonction est toujours envoyé d'un contexte ok
		# et donc on ne revérifie pas la liste
		if liste.length is 0 then return [new RealNumber(0)]
		if liste.length is 1 then return [liste[0].y]
		dx = new RealNumber(1)
		coeffs = [new RealNumber(1)]
		x0 = liste[index].x
		y0 = liste[index].y
		for i in [0..liste.length-1]
			if i isnt index
				xi = liste[i].x
				dx = dx.md(x0.toClone().am(xi, true), false)
				m = coeffs.length
				coeffs[m] = coeffs[m-1].toClone()
				j=m-1
				while j>0
					coeffs[j] = coeffs[j-1].toClone().am(coeffs[j].md(xi, false), true)
					j--
				coeffs[0] = coeffs[0].opposite().md(xi, false)
		coeffs[i] = coeff.md(y0,false).md(dx,true).simplify() for coeff, i in coeffs
		coeffs
	width_roots: (a, roots, variable) ->
		coeffs = [a]
		for xi in roots
			degre = coeffs.length
			coeffs[degre] = coeffs[degre-1].toClone()
			indice = degre-1
			while indice >0
				if typeof coeffs[indice-1] is "undefined" then coeffs[indice] = coeffs[indice].md(xi, false).opposite()
				else coeffs[indice] = coeffs[indice-1].toClone().am(coeffs[indice].md(xi, false), true)
				indice--
			coeffs[0] = coeffs[0].md(xi, false).opposite()
		new Polynome variable, coeffs
	widthCoeffs: (monomes, variable) -> new Polynome variable, monomes
	fromNumberObject: (variable, oNumber) ->
		if oNumber instanceof NumberObject then new Polynome variable, @recursiveFromNumberObject(oNumber.getPolynomeFactors(variable))
		else @invalid()
	recursiveFromNumberObject: (oFactors) ->
		# Cette fonction renvoie un tableau représentant le polynome
		switch
			when oFactors is null then [ new RealNumber() ]
			when typeof oFactors is "number" then [ new RealNumber(oFactors) ]
			when oFactors instanceof NumberObject then [ oFactors ]
			when oFactors.add?
				output = []
				for addFactor in oFactors.add
					addArray = @recursiveFromNumberObject(addFactor)
					output.push(new RealNumber(0)) while output.length<addArray.length
					output[i] = output[i].am(item,false) for item,i in addArray
				output
			when oFactors.mult?
				if oFactors.mult.length is 0 then [ new RealNumber(1) ]
				else
					output = @recursiveFromNumberObject(oFactors.mult.shift())
					while (multFactor=oFactors.mult.shift())?
						multArray = @recursiveFromNumberObject(multFactor)
						add = ( new RealNumber(0) for i in [0..output.length+multArray.length-2])
						# Il faut parcourir tous items de output, tous les items de multArray
						# pour produire un objet résultant du produit
						for it1,i in output
							for it2,j in multArray
								add[i+j] = add[i+j].am(it1.toClone().md(it2,false),false)
						output = add
					output
			when oFactors.power?
				switch
					when oFactors.power is 0 then [ new RealNumber(1) ]
					when oFactors.power is 1 then @recursiveFromNumberObject(oFactors.base)
					else
						base = output = @recursiveFromNumberObject(oFactors.base)
						output = ( it.toClone() for it in base )
						for i in [2..oFactors.power]
							add = ( new RealNumber(0) for i in [0..output.length+base.length-2])
							for it1,i1 in output
								for it2,i2 in base
									add[i1+i2] = add[i1+i2].am( it1.toClone().md(it2,false),false)
							output = add
						output
			when oFactors.monome?
				output = (new RealNumber(0) for i in [1..oFactors.monome])
				output.push(oFactors.factor)
				output
			else []
}

class Polynome
	# Le polynome est un simple tableau de coefficients
	_isValidPolynome: true
	constructor: (variable, monomes) ->
		# Les monomes seront des objets {coeff:NumberObject, power:integer>=0}
		@_monomes = []
		if typeof variable is "string" then @_variable = variable
		else @_variable = "x"
		if monomes?
			@addMonome(i,m) for m,i in monomes
	getVariable: () -> @_variable
	toString: () ->
		if @isNul() then return "0"
		arrOut = []
		for monome in @_monomes
			cs = monome.coeff.compositeString { tex:false }
			power = switch monome.power
				when 0 then "1"
				when 1 then @_variable
				else
					str = @_variable
					str += "*#{@_variable}" for i in [2..monome.power]
					str
			sign = switch
				when cs[1] is false then "-"
				when cs[1] and (arrOut.length>0) then "+"
				else ""
			text = if (cs[0] is "1") and (power isnt "1") then ""
			else cs[0]
			if (power isnt "1")
				if text isnt "" then text+="*"
				text+=power
			arrOut.push(sign+text)
		arrOut.join("")
	toNumberObject: () ->
		if not @isValid() then return new RealNumber()
		if @isNul() then return new RealNumber(0)
		output_arr = ( new Monome(monome.coeff.toClone(), { name:@_variable, power:monome.power}) for monome in @_monomes )
		PlusNumber.makePlus output_arr
	tex: (config) ->
		options = mergeObj { tex:true, canonique:false }, config
		canonique = (options.canonique is true) and (@degre() is 2)
		switch
			when canonique
				a = @getCoeff(2)
				b = @getCoeff(1)
				c = @getCoeff(0)
				xS = b.toClone().opposite().md((new RealNumber(2)).md(a,false),true).simplify()
				yS = @calc(xS)
				if not xS.isNul()
					cs = xS.compositeString options
					output = "\\left("+@_variable
					# inversion du signe devant le xS
					if cs[1] then output = output + "-"
					else output = output + "+"
					output = output+ cs[0] + "\\right)^2"
				else output = @_variable+"^2"
				cs = a.compositeString options
				if cs[0] isnt "1" then output = cs[0]+output
				if not cs[1] then output = "-"+output
				if not yS.isNul()
					cs = yS.compositeString options
					if cs[1] then output = output+"+"+cs[0]
					else output = output+"-"+cs[0]
			else
				if @.isNul() then return "0"
				@unsort()
				cs0 = @monomeToTex(@_monomes[0],options)
				output = cs0[0]
				if @_monomes.length is 1 then return output
				for monome in @_monomes[1..@_monomes.length-1]
					cs = @monomeToTex(monome,options)
					if cs[1] then output = output+"+"
					output = output+cs[0]
		output
	monomeToTex : (monome,options) ->
		cs = monome.coeff.compositeString options
		if cs[1] then output = ""
		else output = "-"
		if cs[0] isnt "1"
			output = output+cs[0]
			if cs[2] and (monome.power>0) then output = "\\left("+output+"\\right)"
		if (monome.power is 0) and (cs[0] is "1") then output = output+"1"
		if monome.power >0 then output = output+@_variable
		if monome.power >1 then output = output+"^{"+monome.power+"}"
		[output,cs[1]]
	simplify: () ->
		i=0
		while i<@_monomes.length
			if (@_monomes[i].coeff.isNul()) then @_monomes.splice(i,1)
			else
				@_monomes[i].coeff = @_monomes[i].coeff.simplify()
				i++
		@
	cleanUpperZeros: () ->
		# On retire les éléments nuls du haut du tableau
		i=0
		while i<@_monomes.length
			if (@_monomes[i].coeff.isNul()) then @_monomes.splice(i,1)
			else i++
		@
	isNul: () -> @_monomes.length is 0
	isReal: () ->
		for monome in @_monomes
			if not monome.coeff.isReal() then return false
		true
	minus: (operand) -> @add(operand, true)
	add: (operand, minus = false) ->
		if not(operand instanceof Polynome) or not @_isValidPolynome or not operand._isValidPolynome then return @setInvalid()
		@addMonome(monome.power, monome.coeff, minus) for monome in operand._monomes
		@
	assignValueToSymbol: (liste) ->
		for key,value of liste
			switch
				when typeof value is "number" then liste[key] = new RealNumber(value)
				when (value instanceof NumberObject) and (value.isFunctionOf().length>0) then liste[key] = new RealNumber()
		monome.coeff = monome.coeff._childAssignValueToSymbol(liste) for monome in @_monomes
		@
	floatify: (symbols) ->
		if not @_isValidPolynome then return new RealNumber()
		x_value = symbols?[@_variable]
		if x_value instanceof NumberObject
			if x_value.isFunctionOf(@_variable) then return new RealNumber()
			x = x_value.floatify(symbols)
		else x = new RealNumber(x_value)
		total = new RealNumber(0)
		# On trie par ordre croissant de puissance
		@sort()
		xp = new RealNumber(1)
		power = 0
		for monome in @_monomes
			while power < monome.power
				xp = xp.md(x,false)
				power++
			total = total.am(monome.coeff.floatify(symbols).md(xp,false),false)
		total
	calc: (x) ->
		# x est un numberobject
		if not @_isValidPolynome then return new RealNumber()
		if x.isFunctionOf(@_variable) then return new RealNumber
		@sort()
		xpow = new RealNumber(1)
		power = 0
		out = new RealNumber(0)
		for monome in @_monomes
			while power<monome.power
				xpow = xpow.md(x,false)
				power++
			out = out.am(monome.coeff.toClone().md(xpow,false),false)
		out.simplify()
	sort: () ->
		# trie dans l'ordre croissant
		@_monomes.sort (a,b) ->
			if a.power>=b.power then return 1
			-1
		@
	unsort: () ->
		# trie dans l'ordre décroissant
		@_monomes.sort (a,b) ->
			if a.power>=b.power then return -1
			1
		@
	module: (symbols) ->
		module = new RealNumber(0)
		coeffDegreMax = null
		degre = -1
		for monome in @_monomes
			coeffFloatified = monome.coeff.floatify(null,symbols).abs()
			module = module.am coeffFloatified, false
			if monome.power>degre
				degre = monome.power
				coeffDegreMax = coeffFloatified
		if degre isnt -1
			module = module.md coeffDegreMax, true
		module
	degre: () ->
		degre = 0
		for monome in @_monomes
			if monome.power>degre then degre = monome.power
		degre
	min_exp: () ->
		if @_monomes.length is 0 then return 0
		output = @_monomes[0].power
		for monome in @_monomes
			if not monome.power < output then output = monome.power
		output
	getCoeff: (power) ->
		if isInteger(power) and (power>=0)
			for monome in @_monomes
				if monome.power is power then return monome.coeff
		new RealNumber(0)
	getRank: (power) ->
		if isInteger(power) and (power>=0)
			for monome, rank in @_monomes
				if monome.power is power then return rank
		undefined
	isValid: () -> @_isValidPolynome
	toClone: () ->
		clone = new Polynome(@_variable)
		clone.addMonome(monome.power,monome.coeff) for monome in @_monomes
		if not @_isValidPolynome then clone.setInvalid()
		clone
	addMonome: (power, coeff, minus = false) ->
		if not @isValid() then return @
		if not isInteger(power) or (power<0) then return @
		unless coeff.isFunctionOf(@_variable) # On ne peut pas insérrer un coeff dépendant de "x"
			rank = @getRank(power)
			if typeof rank isnt "undefined"
				@_monomes[rank].coeff = @_monomes[rank].coeff.am coeff,minus
			else @_monomes.push({power:power, coeff:if minus then coeff.toClone().opposite() else coeff.toClone() })
			@cleanUpperZeros()
	setInvalid: () ->
		if not @_isValidPolynome
			@_isValidPolynome = false
			@_monomes = []
		@
	derivate: ->
		output = new Polynome(@_variable)
		if not @_isValidPolynome then return output.setInvalid()
		for monome in @_monomes
			if monome.power>0 then output.addMonome(monome.power-1, (new RealNumber(monome.power)).md(monome.coeff, false))
		output
	solve_dichotomy: (a,b, decimals, offset = 0) ->
		# Fonction privée
		# a : nombre réel
		# b : nombre réel
		# decimals : nombre de chiffres après la virgule
		# offset : décalage pour résoudre P(x)=0
		# Dans le cas où des coefficients dépendraient de symboles, il faudrait faire précéder le calcul d'un assignValueToSymbol
		if not @_isValidPolynome or not @isReal() then return undefined
		A = @floatify({x:a}).float() - offset
		B = @floatify({x:b}).float() - offset
		if A is 0 then return a
		if B is 0 then return b
		if A*B > 0 then return undefined
		if not isInteger(decimals) or (decimals<1) then decimals = 1
		if decimals > SOLVE_MAX_PRECISION then decimals = SOLVE_MAX_PRECISION
		precision = Math.pow(10,-decimals)
		while Math.abs(A-B) > precision
			m = (a+b)/2
			M = @floatify({x:m}).float() - offset
			if M is 0 then return m
			if A*M > 0
				a = m
				A = M
			else
				b = m
				B = M
		output = (a+b)/2
		Number(output.toFixed(decimals))
	majorant_racines: (offset) ->
		# Permet de donner un majorant à la valeur d'éventuelles racines
		# ce qui permet de borner dans le cas de recherches entre + et - infini
		# offset : dans le cas d'une recherche de solution de P(x)=offset
		coeffs = [ -offset ]
		for monome in @_monomes
			coeff = monome.coeff.floatify().float()
			if coeffs[monome.power]? then coeffs[monome.power]+=coeff
			else coeffs[monome.power] = coeff
		coeffDominant = 0
		coeffDominant = coeffs.pop() while coeffDominant is 0
		if coeffs.length is 0 then return 0
		Math.max (1+Math.abs(coeff/coeffDominant) for coeff in coeffs)...
	solve_numeric: (borne_inf, borne_sup, decimals, offset = 0) ->
		# Fonction privée
		# borne_inf : réel ou string ou objet... peut-être infini
		# borne_sup : réel ou string ou objet...
		# decimals : nombre de chiffres après la virgule
		# offset : décalage pour résoudre P(x)=0
		# Dans le cas où des coefficients dépendraient de symboles, il faudrait faire précéder le calcul d'un assignValueToSymbol
		if not @_isValidPolynome or not @isReal() then return null
		# On cherche les racines de la dérivée afin de définir les bons intervalles
		if @degre() is 0 then return []
		majorant = @majorant_racines(offset)
		if borne_inf? then borne_inf = Math.max(borne_inf,-majorant) else borne_inf = - majorant
		if borne_sup? then borne_sup = Math.min(borne_sup,majorant) else borne_sup = majorant
		if @degre() is 1
			@sort()
			x = -@_monomes[0].coeff.floatify().float()/@_monomes[1].coeff.floatify().float()
			if (x>=borne_inf) and (x<=borne_sup) then return [x]
			else return []
		racines_derivee = @derivate().solve_numeric(borne_inf, borne_sup, decimals)
		a = borne_inf
		racines_derivee.push(borne_sup)
		solutions = []
		for b in racines_derivee
			if (b>a) and (b<=borne_sup)
				x = @solve_dichotomy(a,b,decimals,offset)
				if typeof x isnt "undefined" then solutions.push(x)
				a = b
		solutions
	solveExact: (value,imag) ->
		# On résout poly = value
		# Dans le cas de coefficients dépendant d'un symbole, delta.isNegative revoie false et alors on envisage les deux racines, même si le delta est une expression ne pouvant être que négative
		switch
			when @degre() is 1
				a = @getCoeff(1)
				b = @getCoeff(0).toClone().am(value,true)
				return [ b.opposite().md(a,true) ]
			when @degre() is 2
				a = @getCoeff(2)
				b = @getCoeff(1)
				c = @getCoeff(0).toClone().am(value,true)
				delta = b.toClone().md(b,false).am((new RealNumber(4)).md(a, false).md(c, false), true).simplify()
				neg=false # flag pour se rappeler le signe de delta
				if delta.isNegative()
					if imag
						neg = true
						delta.opposite()
					else return []
				x0 = b.toClone().opposite().md((new RealNumber(2)).md(a, false), true).simplify()
				if delta.isNul() then return [x0]
				sq = delta.sqrt().md((new RealNumber(2)).md(a, false), true)
				if neg then sq = sq.md(new ComplexeNumber(0,1), false)
				return [x0.toClone().am(sq, true).simplify(), x0.toClone().am(sq, false).simplify()]
			else @solve_numeric(null,null,10,0)
	discriminant: () ->
		if @degre() isnt 2 then return new RealNumber()
		a = @getCoeff(2)
		b = @getCoeff(1)
		c = @getCoeff(0)
		return b.toClone().md(b,false).am((new RealNumber(4)).md(a,false).md(c,false),true).simplify()
