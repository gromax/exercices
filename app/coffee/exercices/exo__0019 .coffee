
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
			ineq = inp.ineq = Proba.aleaEntreBornes(0,3) # <, >, <=, >=
			# 1 fois sur 4, on aura un delta<0
			a = Proba.aleaEntreBornes(1,3)*Proba.aleaSign()
			if Proba.aleaEntreBornes(1,4) is 1
				im = Proba.aleaEntreBornes(1,10)
				re = Proba.aleaEntreBornes(-10,10)
				b = -2*re*a
				c = (re*re+im*im)*a
			else
				x1 = x2 = Proba.aleaEntreBornes(-10,10)
				x2 = Proba.aleaEntreBornes(-10,10)
				b = (-x1-x2)*a
				c = x1*x2*a
			inp.a = a
			inp.b = b
			inp.c = c
		poly = Polynome.make [c, b, a]
		a_is_plus = (a>0) # convexe
		sol_is_ext = (a_is_plus is ((ineq is 1) or (ineq is 3))) # ensemble à l'extérieur des racines
		sol_xor = ((ineq >= 2) isnt sol_is_ext) # On construit l'ensemble solution en prenant d'abord l'espace à l'intérieur des racines. Si sol_is_ext, il faudra inverser l'ensemble. Dans l'ensemble initial, on prend donc les racines si : * ext et strict (alors les racines ne seront pas dans la sol) * int et large (alors les racines y seront), c'est donc un xor qu'il faut faire
		racines = poly.solveExact(0,false)
		ensemble_solution = new Ensemble()
		# on prépare les tableaux de signes
		if racines.length is 1
			if sol_xor then ensemble_solution.insertSingleton racines[0]
			tabX = ["$-\\infty$", "$x_0$","$+\\infty$"]
			tabS1 = ",-,z,-,"
			tabS2 = ",+,z,+,"
		else if racines.length is 2
			ensemble_solution.init(sol_xor,racines[0], sol_xor,racines[1])
			tabX = ["$-\\infty$", "$x_1$", "$x_2$", "$+\\infty$"]
			tabS1 = ",-,z,+,z,-,"
			tabS2 = ",+,z,-,z,+,"
		else
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
			new BDiscriminant {
				data:data
				bareme:20
				discriminant:poly.discriminant()
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
