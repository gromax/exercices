
Exercice.liste.push
	id:33
	title:"Équation modulo $2\\pi$"
	description:"Résoudre une équation portant sur des mesures angulaires en radians, avec un terme $2k\\pi$."
	keyWords:["Trigonométrie","Algèbre","Équation","Première"]
	init: (data) ->
		inp = data.inputs
		if inp.a? then a = Number inp.a
		else a = inp.a = Proba.aleaEntreBornes 3,5
		a = NumberManager.makeNumber a
		if inp.b? then b= Number inp.b
		else b = inp.b = a - Proba.aleaEntreBornes 1,5
		b = NumberManager.makeNumber b
		if inp.ang1? then ang1= Number inp.ang1
		else ang1 = inp.ang1 = Proba.aleaEntreBornes(1,6)*30*Proba.aleaSign()
		ang1 = Trigo.degToRad ang1
		if inp.ang2? then ang2= Number inp.ang2
		else ang2 = inp.ang2 = Proba.aleaEntreBornes(1,6)*30*Proba.aleaSign()
		ang2 = Trigo.degToRad ang2
		x = NumberManager.makeSymbol("x")
		membreGaucheTex = x.toClone().md(a,false).am(ang1,false).simplify().tex()
		membreDroiteTex = x.md(b,false).am(ang2,false).simplify().am(Trigo.pi("2k"),false).tex()
		xCoeff = a.toClone().am(b,true)
		modulo = Trigo.pi(NumberManager.makeNumber(2).md(xCoeff.abs(),true)).simplify()
		good_solutions = [ang2.toClone().am(ang1,true).md(xCoeff,true).developp().simplify().setModulo(modulo)]
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation { gauche:membreGaucheTex, droite:membreDroiteTex }
			}]}
			new BSolutions {
				data:data
				bareme:100
				touches:["pi"]
				solutions:good_solutions
				moduloKey:"k"
			}
		]
