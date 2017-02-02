
Exercice.liste.push
	id:19
	title:"Inéquation du second degré"
	description:"Il faut résoudre une inéquation du second degré."
	keyWords:["Analyse","Trinome","Équation","Racines","Première"]
	init: (data) ->
		inp = data.inputs
		if (typeof inp.a isnt "undefined") and (typeof inp.b isnt "undefined") and (typeof inp.c isnt "undefined") and (typeof inp.ineq isnt "undefined")
			a = Number inp.a
			b = Number inp.b
			c = Number inp.c
			ineq = Number inp.ineq
		else
			ineq = inp.ineq = mM.alea.real [0,1,2,3] # <, >, <=, >=
			# 1 fois sur 4, on aura un delta<0
			a = mM.alea.real { min:1, max:3, sign:true }
			if mM.alea.dice(1,4)
				im = mM.alea.real { min:1, max:10 }
				re = mM.alea.real { min:-10, max:10 }
				b = -2*re*a
				c = (re*re+im*im)*a
			else
				x1 = mM.alea.real { min:-10, max:10 }
				x2 = mM.alea.real { min:-10, max:10 }
				b = (-x1-x2)*a
				c = x1*x2*a
			inp.a = a
			inp.b = b
			inp.c = c
		poly = mM.polynome.make { coeffs:[c, b, a] }
		a_is_plus = (a>0) # convexe
		sol_is_ext = (a_is_plus is ((ineq is 1) or (ineq is 3))) # ensemble à l'extérieur des racines
		sol_xor = ((ineq >= 2) isnt sol_is_ext) # On construit l'ensemble solution en prenant d'abord l'espace à l'intérieur des racines. Si sol_is_ext, il faudra inverser l'ensemble. Dans l'ensemble initial, on prend donc les racines si : * ext et strict (alors les racines ne seront pas dans la sol) * int et large (alors les racines y seront), c'est donc un xor qu'il faut faire
		racines = mM.polynome.solve.exact poly, { y:0 }
		# on prépare les tableaux de signes
		switch racines.length
			when 1
				if sol_xor then ensemble_solution = mM.ensemble.singleton racines[0]
				else ensemble_solution = mM.ensemble.vide()
				tabX = ["$-\\infty$", "$x_0$","$+\\infty$"]
				tabS1 = ",-,z,-,"
				tabS2 = ",+,z,+,"
			when 2
				ensemble_solution = mM.ensemble.intervalle sol_xor,racines[0], racines[1], sol_xor
				tabX = ["$-\\infty$", "$x_1$", "$x_2$", "$+\\infty$"]
				tabS1 = ",-,z,+,z,-,"
				tabS2 = ",+,z,-,z,+,"
			else
				ensemble_solution = mM.ensemble.vide()
				tabX = ["$-\\infty$", "$+\\infty$"]
				tabS1 = ",-,"
				tabS2 = ",+,"
		if sol_is_ext then ensemble_solution.inverse()
		if a_is_plus then goodTab = 1
		else goodTab=0
		# On définit un tableau donnant la suite des étapes
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation { gauche:poly.tex(), droite:"0", ineq:h_ineqSymb[ineq] }
			}]}
			new BListe {
				title: "Calcul du discriminant $\\Delta$"
				data:data
				bareme:20
				liste: [
					tag:"$\\Delta =$"
					name:"delta"
					description:"Discriminant"
					good:poly.discriminant()
				]
				aide: oHelp.trinome.discriminant
			}
			new BSolutions {
				data:data
				bareme:40
				aKey:"racines"
				touches:["sqrt"]
				aide: oHelp.trinome.racines
				solutions:racines
			}
			new BWichTab {
				data:data
				bareme:20
				tableaux:[(new TabVar(tabX)).addSignLine(tabS1), (new TabVar(tabX)).addSignLine(tabS2)]
				good:goodTab
			}
			new BEnsemble {
				data:data
				bareme:20
				ensemble_solution:ensemble_solution
			}
		]
