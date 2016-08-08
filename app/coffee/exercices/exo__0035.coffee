
Exercice.liste.push
	id:35
	title:"Équation de type $\\cos (a\\cdot x+b) = \\cos \\alpha$"
	description:"Résoudre une équation de la forme $\\cos x = \\cos \\alpha$ $\\sin x = \\sin \\alpha$."
	keyWords:["Trigonométrie","Algèbre","Équation","Première"]
	init: (data) ->
		inp = data.inputs
		if inp.a? then a= Number inp.a
		else inp.a = a = Proba.aleaEntreBornes 2,5
		a = NumberManager.makeNumber a
		if inp.ang1? then ang1= Number inp.ang1
		else inp.ang1 = ang1 = Proba.aleaEntreBornes(1,6)*30*Proba.aleaSign()
		ang1 = Trigo.degToRad ang1
		if inp.ang2? then ang2= Number inp.ang2
		else inp.ang2 = ang2 = Proba.aleaEntreBornes(1,6)*30*Proba.aleaSign()
		ang2 = Trigo.degToRad ang2
		if typeof inp.type? then type=inp.type
		else inp.type = type = Proba.aleaIn ["cos","sin"]
		x = NumberManager.makeSymbol("x")
		membreGauche = x.toClone().md(a,false).am(ang1,false).simplify().applyFunction(type).tex()
		membreDroite = ang2.toClone().applyFunction(type).tex()
		modulo = Trigo.pi(NumberManager.makeNumber(2).md(a,true)).simplify()
		ang = ang2.toClone().am(ang1,true).md(a,true).simplify()
		if type is "cos"
			solutions = [ang.toClone().setModulo(modulo), ang.opposite().setModulo(modulo)]
		else
			solutions = [ang.toClone().setModulo(modulo), Trigo.mesurePrincipale(Trigo.pi().am(ang,true)).simplify().setModulo(modulo)]
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation {
					gauche:membreGauche
					droite:membreDroite
					modulo:"\\frac{2k\\pi}{#{inp.a}}"
				}
			}]}
			new BSolutions {
				data:data
				bareme:100
				touches:["pi"]
				solutions:solutions
			}
		]
