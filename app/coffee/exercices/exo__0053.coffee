
Exercice.liste.push
	id:53
	title:"Équations avec logarithme et exponentielle"
	description:"Résoudre des équations contenant des logarithmes et des exponentielles."
	keyWords:["logarithme","exponentielle","équation","TSTL"]
	options: {
		a:{ tag:"ln ou exp" , options:["ln()", "exp()", "e^()"] , def:0 }
		b:{ tag:"équation", options:["f(ax+b)=f(cx+d)","a.f(x)+b = c.f(x)+d","a.f²(x)+...=0,","c.f(ax+b).d=...","a.f²(ax+b)+...=0"], def:0 }
	}
	init: (data) ->
		a = data.options.a.value
		b = data.options.b.value
		# a = 0 pour une équation en ln ; 1 et 2 pour exp (changement de notation)
		# b = 0 pour ln(expr 1) = ln(expr 2) (ou exp)
		# b = 1 pour 3 ln(x) +2 = 2 ln(x) -1 (ou exp)
		# b = 2 pour ln(x)^2 - 5 ln(x) + 2 =0
		# b = 3 pour 3 ln(expr) +2 = 2 ln(expr) -1 (ou exp)
		# b = 4 pour ln(expr)^2 - 5 ln(expr) + 2 =0
		switch
			when typeof data.inputs.b isnt "undefined"
				expr = mM.toNumber(data.inputs.b)
				expr1 = mM.toNumber(data.inputs.c ? "x")
				expr2 = mM.toNumber(data.inputs.d ? "0")
				a = Number(data.inputs.a ? a)
				{ goods, tex } = @cas_b12(expr,expr1,expr2,a)
			when (typeof data.inputs.c isnt "undefined") and (typeof data.inputs.d isnt "undefined")
				expr1 = mM.toNumber(data.inputs.c)
				expr2 = mM.toNumber(data.inputs.d, "x")
				a = Number(data.inputs.a ? a)
				{ goods, tex } = @cas_b0(expr1,expr2,a)
			else
				# On commence par créer expr qui sera dans ln ou exp
				# Cas b = 2, il faut un polynome
				if (b is 2) or (b is 4)
					if b is 4 then expr = mM.alea.poly { degre:1, coeffDom:{ min:1, max:5, sign:true }, values:{min:-10, max:10} }
					else expr = mM.exec ["x"]
					if a is 0 then xS = mM.alea.real { values:{min:-10, max:10} }
					else xS = mM.alea.real { values:{min:0, max:10} } # Pour une équation en exp, on prendra le ln, il vaut mieux qu'il y ait des sol>0
					# Une fois sur 8 on prend le cas sans solution
					if mM.alea.dice(1,8)
						yS = mM.alea.real { values:{min:-20, max:20} }
						opp = (yS<0)
					else
						yS = mM.alea.real { min:1, max:10, sign:true }
						opp = (yS>0)
						yS = yS*yS
					if opp then expr1 = mM.exec [ "x", xS, "-", 2, "^", "*-", yS, "+"], { simplify:true, developp:true }
					else expr1 = mM.exec [ "x", xS, "-", 2, "^", yS, "-"], { simplify:true, developp:true }
					expr2 = mM.toNumber 0
					data.inputs.a = String a
					data.inputs.b = String expr
					data.inputs.c = String expr1
					{ goods, tex } = @cas_b12(expr,expr1,expr2,a)
				if (b is 1) or (b is 3)
					if b is 3 then expr = mM.alea.poly { degre:1, coeffDom:{ min:1, max:5, sign:true }, values:{min:-10, max:10} }
					else expr = mM.exec ["x"]
					a1 = mM.alea.real { min:-10, max:10 }
					aff1 = mM.alea.poly { degre:1, coeffDom:a1, values:{min:-10, max:10} }
					aff2 = mM.alea.poly { degre:1, coeffDom:{min:-10, max:10, no:[a1]}, values:{min:-10, max:10} }
					data.inputs.a = String a
					data.inputs.b = String expr
					data.inputs.c = String expr1
					data.inputs.d = String expr1
					{ goods, tex } = @cas_b12(expr,aff1,aff2,a)
				if b is 0
					a1 = mM.alea.real { min:-10, max:10 }
					expr1 = mM.alea.poly { degre:1, coeffDom:a1, values:{min:-10, max:10} }
					expr2 = mM.alea.poly { degre:1, coeffDom:{min:-10, max:10, no:[a1]}, values:{min:-10, max:10} }
					data.inputs.a = String a
					data.inputs.c = String expr1
					data.inputs.d = String expr1
					{ goods, tex } = @cas_b0(expr1,expr2,a)
		[
			new BEnonce {title:"Énoncé", zones:[{body:"enonce", html:"<p>On considère l'équation : $#{ tex }$.</p><p>Vous devez donner la ou les solutions de cette équations, si elles existent.</p><p><i>S'il n'y a pas de solution, écrivez $\\varnothing$. s'il y a plusieurs solutions, séparez-les avec ;</i></p>"}]}
			new BSolutions {
				data:data
				bareme:100
				solutions:goods
			}
		]
	cas_b0: (expr1,expr2,a) ->
		diff = mM.exec [ expr1, expr2, "-"], {simplify:true}
		pol = mM.polynome.make diff
		goods_not_verified = mM.polynome.solve.exact pol
		goods = []
		for it in goods_not_verified
			if (a isnt 0) or expr1.floatify({x:it}).isPositive() then goods.push it
		if (a is 0) then fct = "ln" else fct = "exp"
		mg = mM.exec [expr1, fct]
		md = mM.exec [expr2, fct]
		if a is 1 then options = { altFunctionTex:["exp"] } else options = {}
		{ goods:goods, tex:mg.tex(options)+" = "+md.tex(options) }
	cas_b12: (expr,expr1,expr2,a) ->
		diff = mM.exec [ expr1, expr2, "-"], {simplify:true}
		pol = mM.polynome.make diff
		goods_not_verified = mM.polynome.solve.exact pol
		goods = []
		pol = mM.polynome.make expr
		for it in goods_not_verified
			xs = null
			if a is 0 then xs = mM.polynome.solve.exact(pol, { y:mM.exec([it, "exp"]) })
			else if it.isPositive() then xs = mM.polynome.solve.exact(pol, { y:mM.exec([it, "ln"]) })
			if xs isnt null
				goods.push(x) while (x=xs.pop()?.simplify(null,true))
		if a is 0 then X = mM.exec [expr, "ln"]
		else X = mM.exec [expr, "exp"]
		if a is 2
			mg = expr1.replace(X, "x").simplify().order() # afin d'intégrer la puissance 2 dans le e^
		else
			mg = expr1.replace(X, "x").order()
		md = expr2.replace(X,"x").order()
		if a is 1 then options = { altFunctionTex:["exp"] } else options = {}
		{ goods:goods, tex:mg.tex(options)+" = "+md.tex(options) }


