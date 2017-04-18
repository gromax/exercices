
Exercice.liste.push
	id:60
	title:"Intégrer une fonction"
	description:"Intégrer une fonction."
	keyWords:["Analyse", "fonction", "Intégration", "TSTLB"]
	options: {
		a:{ tag:"type", options:["alea", "K.exp(ax)", "polynome", "ax+b+c/x"], def:0}
	}
	init: (data) ->
		aide=["Pour calculer $\\mathcal{A} = \\int_a^b f(x) dx$, il faut d'abord déterminer une primitive de $f$, c'est à dire une fonction $F$ telle que $F'=f$. Alors : $\\mathcal{A} = [F(x)]_a^b = F(b)-F(a)$."]
		if data.inputs.t? then t = Number data.inputs.t
		else
			t = data.options.a.value ? 0
			if t is 0 then t = mM.alea.in [1,2,3]
			data.inputs.t = String t
		switch t
			when 1
				if (data.inputs.m?) and (data.inputs.M?) and (data.inputs.K?) and (data.inputs.a?)
					a = Number data.inputs.a
					m = Number data.inputs.m
					M = Number data.inputs.M
					K = Number data.inputs.K
				else
					data.inputs.K = String(K = mM.alea.real {min:2, max:100})
					data.inputs.a = String(a = mM.alea.real {min:0.01, max:0.5, real:2, sign:true})
					xmin = -2/Math.abs(a)
					xmax = 2/Math.abs(a)
					data.inputs.m = String(m = mM.alea.real { min:xmin, max:xmax-2 })
					data.inputs.M = String(M = mM.alea.real { min:m+1, max:xmax})
				fct = mM.exec [K, a, "x", "*", "exp", "*"], {simplify:true}
				aE = a*100
				# Il y a les problèmes de décimales habituelles avec javascript
				aM = fixNumber(a*M,2)
				am = fixNumber(a*m,2)
				good = mM.exec [K, aE, "/", 100, "*", aM, "exp", am, "exp", "-", "*"], {simplify:true}
			when 2
				if (data.inputs.m?) and (data.inputs.M?) and (data.inputs.P?)
					m = Number data.inputs.m
					M = Number data.inputs.M
					coeffs = ( Number c for c in data.inputs.P.split("|") )
					[coeff0, coeff1, coeff2] = coeffs
				else
					coeff2 = mM.alea.real { min:-5, max:5 }
					if coeff2 is 0 then coeff1 = mM.alea.real { min:1, max:10, sign:true }
					else coeff1 = mM.alea.real { min:-10, max:10 }
					coeff0 = mM.alea.real { min:-10, max:10 }
					data.inputs.m = String(m = mM.alea.real { min:0, max:8 })
					data.inputs.M = String(M = mM.alea.real { min:m+1, max:10 })
					# Il faut s'assurer que la fonction est bien positive tout le long de l'intervalle [m;M]
					if (g=(coeff2*m+coeff1)*m+coeff0) <0 then coeff0 -= g
					if (g=(coeff2*M+coeff1)*M+coeff0) <0 then coeff0 -= g
					if (coeff2 > 0) and (sommet=-coeff1/(2*coeff2) > m) and (sommet<M) and ((g=(coeff2*sommet+coeff1)*sommet+coeff0) <0) then coeff0 -= g
					coeffs = [coeff0, coeff1, coeff2]
					data.inputs.P = coeffs.join("|")
				fct = mM.polynome.make { coeffs:coeffs, type:"number" }
				good = mM.exec [ coeff2, 3, "/", M, "*", coeff1, 2, "/", "+", M, "*", coeff0, "+", M, "*", coeff2, 3, "/", m, "*", coeff1, 2, "/", "+", m, "*", coeff0, "+", m, "*", "-"], { simplify:true }
			when 3
				# forme ax+b+c/x
				if (data.inputs.m?) and (data.inputs.M?) and (data.inputs.c?)
					m = Number data.inputs.m
					M = Number data.inputs.M
					[a,b,c] = ( Number c for c in data.inputs.c.split("|") )
				else
					a = mM.alea.real { min:1, max:5 }
					if a is 0 then b = mM.alea.real { min:1, max:10 }
					else b = mM.alea.real { min:-10, max:10 }
					c = mM.alea.real { min:1, max:5, sign:true }
					data.inputs.m = String(m = mM.alea.real { min:1, max:8 })
					data.inputs.M = String(M = mM.alea.real { min:m+1, max:10 })
					# Il faut s'assurer que la fonction est bien positive tout le long de l'intervalle [m;M]
					# Quand c<0, la fonction est croissante
					if c<0
						if (g=a*m+b+c/m) <0 then b -= g
					else
						# Le minimum est atteint pour sqrt(c/a)
						# décroissant avant, croissant après
						sommet = Math.sqrt(c/a)
						switch
							when (sommet<m)
								if((g=a*m+b+c/m) <0) then b -= g
							when (sommet>M)
								if((g=a*M+b+c/M) <0) then b -= g
							else
								if ((g=a*sommet+b+c/sommet) <0) then b -= g
					data.inputs.c = [a,b,c].join("|")
				fct = mM.exec [a, "x", "*", b, "+", c, "x", "/", "+"], {simplify:true}
				good = mM.exec [ a, 2, "/", M, "*", b, "+", M, "*", c, M, m, "/", "ln", "*", "+", a, 2, "/", m, "*", b, "+", m, "*", "-"], { simplify:true }
				aide= aide.concat ["Vous pouvez simplifier le résultat en vous rappelant que $ln(a)-ln(b) = ln\\left(\\frac{a}{b}\\right)$"]

		fdx = mM.exec [ fct, "Symbol:dx", "*"]
		tex = data.tex = "\\displaystyle \\int_{#{m}}^{#{M}} #{fdx.tex({negPowerDown:true})}"
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>Déterminez la valeur exacte de $\\mathcal{A} = #{tex}$</p>"}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Expression de $f'$"
				liste:[{
					tag:"$\\mathcal{A}$"
					name:"A"
					description:"Expression de l'intégrale"
					good: good
				}]
				aide:aide
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Calculez les valeurs exates des intégrales suivantes :"
				items: ("$x \\mapsto #{item.tex}$" for item in data)
				large:false
			}
		}
