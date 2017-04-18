
Exercice.liste.push
	id:53
	title:"Équations avec logarithme et exponentielle"
	description:"Résoudre des équations contenant des logarithmes et des exponentielles."
	keyWords:["logarithme","exponentielle","équation","TSTL"]
	options: {
		a:{ tag:"ln ou exp" , options:["ln()", "exp()", "e^()"] , def:0 }
		b:{ tag:"équation", options:["f(ax+b)=f(cx+d)","a.f(x)+b = c.f(x)+d","a.f²(x)+...=0,","c.f(ax+b)+d=...","a.f²(ax+b)+...=0"], def:0 }
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
		infos = []
		# Dans le cas b = 1 à 4 on stocke dans inputs.b l'expression dans ln/exp et dans c l'expression du premier membre et éventuellement d au second membre
		# dans le cas b=0, on se contente de c et d qui sont les expressions dans ln/exp au premier et second membre
		switch
			when typeof data.inputs.b isnt "undefined"
				expr = mM.toNumber(data.inputs.b)
				expr1 = mM.toNumber(data.inputs.c ? "x")
				expr2 = mM.toNumber(data.inputs.d ? "0")
				a = Number(data.inputs.a ? a)
				{ goods, eqTex } = @cas_b12(expr,expr1,expr2,a)
			when (typeof data.inputs.c isnt "undefined") and (typeof data.inputs.d isnt "undefined")
				expr1 = mM.toNumber(data.inputs.c)
				expr2 = mM.toNumber(data.inputs.d, "x")
				a = Number(data.inputs.a ? a)
				{ goods, eqTex } = @cas_b0(expr1,expr2,a)
			else
				# On commence par créer expr qui sera dans ln ou exp
				switch
					when (b is 2) or (b is 4)
						# Cas d'un polynome du second degré
						# On choisit l'expression qui ira dans le ln/exp : soit ax+b, soit x
						if b is 4 then expr = mM.alea.poly { degre:1, coeffDom:{ min:1, max:5, sign:true }, values:{min:-10, max:10} }
						else expr = mM.exec ["x"]
						# Il faut d'abord résoudre une équation du second degré, puis prendre le ln (si a=1) ou le exp (si a=0) Donc on prend une parabole. Pour le cas a=1, on place un sommet xS>0 pour garantir l'existence d'une racine positive, s'il y a des racines
						if a is 0 then xS = mM.alea.real { values:{min:-10, max:10} }
						else xS = mM.alea.real { values:{min:0, max:10} }
						# Une fois sur 8 on prend le cas d'une fonction du second degré sans racine
						# Je ne prend que des parabole convexe
						if mM.alea.dice(1,8)
							yS = mM.alea.real { values:{min:1, max:20} }
							expr1 = mM.exec [ "x", xS, "-", 2, "^", yS, "+"], { simplify:true, developp:true }
						else
							sqrtYS = mM.alea.real { min:1, max:10 }
							expr1 = mM.exec [ "x", xS, "-", 2, "^", sqrtYS, 2, "^", "-"], { simplify:true, developp:true }
						expr2 = mM.toNumber 0
						data.inputs.a = String a
						data.inputs.b = String expr
						data.inputs.c = String expr1
						{ goods, eqTex } = @cas_b12(expr,expr1,expr2,a)
						if a is 0 then infos.push { class:"info", html:"La notation $\\ln^2(#{expr.tex()})$ est un racourci pour $\\left(\\ln(#{expr.tex()})\\right)^2$"}
						if a is 1 then infos.push { class:"info", html:"La notation $\\exp^2(#{expr.tex()})$ est un racourci pour $\\left(\\exp(#{expr.tex()})\\right)^2$"}
					when (b is 1) or (b is 3)
						if b is 3 then expr = mM.alea.poly { degre:1, coeffDom:{ min:1, max:5, sign:true }, values:{min:-10, max:10} }
						else expr = mM.exec ["x"]
						# On aura u.ln(ax+b)+v = w.ln(ax+b)+t
						# Dans le cas d'une exponentielle, il faut être sûr que la solution (t-v)/(u-w)>0
						u = mM.alea.real { min:-10, max:10 }
						v = mM.alea.real { min:-10, max:10 }
						w = mM.alea.real { min:-10, max:10, no:[u] }
						if a is 0 then t = mM.alea.real { min:-10, max:10 }
						else
							tm = Math.floor(-v/(u-w)+1)
							t = mM.alea.real { min:tm, max:tm+15 }
						aff1 = mM.exec [u, "x", "*", v, "+"], { simplify:true}
						aff2 = mM.exec [w, "x", "*", t, "+"], { simplify:true}
						data.inputs.a = String a
						data.inputs.b = String expr
						data.inputs.c = String aff1
						data.inputs.d = String aff2
						{ goods, eqTex } = @cas_b12(expr,aff1,aff2,a)
					else
						# on résout ln(u x+v) = ln(w x +t)
						u = mM.alea.real { min:1, max:20 }
						w = mM.alea.real { min:1, max:20, no:[u] }
						v = mM.alea.real { min:-10, max:10 }
						t = mM.alea.real { min:-10, max:10 }
						# Il faut contrôler l'absence ou la présence de solutions
						x0 = (t-v)/(u-w)
						g = Math.min(u*x0+v,w*x0+t)
						if dice(1,8) and (a is 0)
							# une fois sur 8, on ne veut pas de solution
							if (g>0)
								t -= g+1
								v -= g+1
						else
							if (a is 0) and (g<0)
								t -= g-1
								v -= g-1
						expr1 = mM.exec [u, "x", "*", v, "+"], { simplify:true }
						expr2 = mM.exec [w, "x", "*", t, "+"], { simplify:true }
						data.inputs.a = String a
						data.inputs.c = String expr1
						data.inputs.d = String expr2
						if a is 0 then infos.push { class:"warning", html:"Si vous trouvez une solution, pensez à vérifier si l'équation est bien définie pour cette valeur. Par exemple $\\ln(3x-4)$ n'est pas défini pour $x=1$ car $3\\cdot 1 - 4 = -1$"}
						{ goods, eqTex } = @cas_b0(expr1,expr2,a)
		if infos.length > 0 then infosZone = { list:"infos", items:infos }
		else infosZone = { vide:true }
		data.equation = eqTex
		[
			new BEnonce {
				title:"Énoncé"
				zones:[
					{body:"enonce", html:"<p>On considère l'équation : $#{ eqTex }$.</p><p>Vous devez donner la ou les solutions de cette équations, si elles existent.</p><p><i>S'il n'y a pas de solution, écrivez $\\varnothing$. s'il y a plusieurs solutions, séparez-les avec ;</i></p>"}
					infosZone
				]
			}
			new BListe {
				title:"Solutions"
				data:data
				bareme:100
				touches:["empty"]
				liste:[{
					name:"solutions"
					tag:"$\\mathcal{S}$"
					large:true
					solutions:goods
				}]
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
		{ goods:goods, eqTex:mg.tex(options)+" = "+md.tex(options) }
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
		{ goods:goods, eqTex:mg.tex(options)+" = "+md.tex(options) }
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] { items: ("$#{item.equation}$" for item in data), large:false }
		}


