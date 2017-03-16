
Trigo = {
	sin: (angle) -> @cos angle,true
	cos: (angle,forSin=false) ->
		# angle est un angle en degrés donné comme un float
		# forSin permet de demander le sinus, il faut faire 90-angle pour qu'un cos convienne
		# avec cos, une val abs ne change pas la valeur
		if forSin then pval = Math.abs 90-angle
		else pval = Math.abs angle
		# On cherche une valeur principale
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
			else output = new RealNumber(Math.cos angle/180*Math.PI)
		if sign then output.opposite()
		output
	aCos: (_cos,_sin_is_plus,rad=true) ->
		# demande une _cos float
		# _sin_is_plus indique si le sin est > 0
		sup90 = (_cos<0)
		_cos = Math.abs(_cos)
		switch _cos
			when 1 then out = 0
			when (Math.sqrt(6)+Math.sqrt(2))/4 then out = 15
			when Math.sqrt(3)/2 then out = 30
			when (1+Math.sqrt(5))/4 then out = 36
			when Math.sqrt(2)/2 then out = 45
			when 1/2 then out = 60
			when (Math.sqrt(5)-1)/4 then out = 72
			when (Math.sqrt(6)-Math.sqrt(2))/4 then out = 75
			when 0 then out = 90
			else out = Math.acos(_cos)*180/Math.PI
		if sup90 then out = 180-out
		if _sin_is_plus is false then out = - out
		out = new RealNumber out
		if rad then out.md(new RealNumber(180),true).md(SymbolManager.pi(),false).simplify()
		else out
	anglesConnus: ()-> [0,30,45,60,90,120,135,150,180,-30,-45,-60,-90,-120,-135,-150]
}

