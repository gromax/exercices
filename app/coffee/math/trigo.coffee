
class @Trigo
	@pi: (factor)->
		if factor? then NumberManager.makeNumber(factor).md(SymbolNumber.pi(),false)
		else SymbolNumber.pi()
	@radToDegree: (value) ->
		if typeof value is "number"
			# On considère qu'une approx suffira
			return new RealNumber value*180/Math.PI
		if value instanceof RealNumber
			# On considère qu'une approx suffira
			return new RealNumber value.toNumber()*180/Math.PI
		if value instanceof NumberObject
			return value.toClone().md(new RealNumber(180),false).md(SymbolNumber.makeSymbol("pi"),true).simplify()
		return new RealNumber()
	@degToRad: (value) ->
		# préformatage
		unless value instanceof NumberObject then value = NumberManager.makeNumber value
		return value.toClone().md(new RealNumber(180),true).md(SymbolNumber.makeSymbol("pi"),false).simplify()
	@cos: (value,forSin=false) ->
		# forSin permet de demander le sinus, il faut faire 90-angle pour qu'un cos convienne
		# avec cos, une val abs ne change pas la valeur
		if forSin then pval = Math.abs 90-@radToDegree(value).toNumber()
		else pval = Math.abs @radToDegree(value).toNumber()
		# On cherche un valeur principale
		pval -= 360 while pval>180
		pval = Math.abs pval
		if pval>90
			sign = true
			pval = 180-pval
		switch
			when pval is 0 then output = new RealNumber 1
			when pval is 15 then output = (new RadicalNumber()).addFactor(6,new RationalNumber(1,4),false).addFactor(2,new RationalNumber(1,4),false)
			when pval is 30 then output = (new RadicalNumber()).addFactor(3,new RationalNumber(1,2),false)
			when pval is 36 then output = (new RadicalNumber()).addFactor(1,new RationalNumber(1,4),false).addFactor(5,new RationalNumber(1,4),false)
			when pval is 45 then output = (new RadicalNumber()).addFactor(2,new RationalNumber(1,2),false)
			when pval is 60 then output = new RationalNumber(1,2)
			when pval is 72 then output = (new RadicalNumber()).addFactor(5,new RationalNumber(1,4),false).addFactor(1,new RationalNumber(1,4),true)
			when pval is 75 then output = (new RadicalNumber()).addFactor(6,new RationalNumber(1,4),false).addFactor(2,new RationalNumber(1,4),true)
			when pval is 90 then output = new RealNumber 0
			else output = new RealNumber(Math.cos value.toNumber())
		if sign then output.opposite()
		output
	@aCos: (value,pos,rad=true) ->
		if value instanceof NumberObject then value=value.toNumber()
		sup90 = (value<0)
		value = Math.abs(value)
		switch value
			when 1 then out = 0
			when (Math.sqrt(6)+Math.sqrt(2))/4 then out = 15
			when Math.sqrt(3)/2 then out = 30
			when (1+Math.sqrt(5))/4 then out = 36
			when Math.sqrt(2)/2 then out = 45
			when 1/2 then out = 60
			when (Math.sqrt(5)-1)/4 then out = 72
			when (Math.sqrt(6)-Math.sqrt(2))/4 then out = 75
			when 0 then out = 90
			else out = Math.acos(value)*180/Math.PI
		if sup90 then out = 180-out
		unless pos then out = - out
		if rad then return @degToRad(out)
		return NumberManager.makeNumber out
	@sin: (value) -> @cos value,true
	@cosObject: (objValue) -> FunctionNumber.cos objValue
	@sinObject: (objValue) -> FunctionNumber.sin objValue
	@mesurePrincipale: (value) ->
		nPi = value.toNumber()/Math.PI
		tours = Math.round(nPi/2)*2
		output = value.toClone().am (new RealNumber tours).md(SymbolNumber.pi(),false), true
		if nPi-tours is -1 then output.opposite()
		output
	@anglesConnus: ()-> [0,30,45,60,90,120,135,150,180,-30,-45,-60,-90,-120,-135,-150]
	@complexe:(module,argument) ->
		unless module instanceof NumberObject then module = NumberManager.makeNumber module
		@cos(argument).md(module,false).am(@sin(argument).md(module,false).md(NumberManager.makeI(),false),false).simplify()

