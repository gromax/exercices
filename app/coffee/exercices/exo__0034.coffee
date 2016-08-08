
Exercice.liste.push
	id:34
	title:"Équation de type $\\cos x = \\cos \\alpha$"
	description:"Résoudre une équation de la forme $\\cos x = \\cos \\alpha$ $\\sin x = \\sin \\alpha$."
	keyWords:["Trigonométrie","Algèbre","Équation","Première"]
	init: (data) ->
		inp = data.inputs
		if inp.ang? then ang= Number inp.ang
		else inp.ang = ang = Proba.aleaEntreBornes(1,12)*15*Proba.aleaSign()
		if inp.type? then type=inp.type # sin ou cos
		else inp.type = type = Proba.aleaIn ["cos","sin"]
		angRad = Trigo.degToRad ang
		x = NumberManager.makeSymbol("x")
		if type is "cos"
			membreGauche = Trigo.cosObject(x).tex()
			membreDroite = Trigo.cosObject(angRad).tex()
			if (Math.abs(ang) % 180) is 0 then solutions = [angRad.toClone().setModulo(Trigo.pi(2))]
			else solutions = [angRad.toClone().setModulo(Trigo.pi(2)), angRad.opposite().setModulo(Trigo.pi(2))]
		else
			membreGauche = Trigo.sinObject(x).tex()
			membreDroite = Trigo.sinObject(angRad).tex()
			if ((Math.abs(ang)+90)%180) is 0 then solutions = [angRad.toClone().setModulo(Trigo.pi(2))]
			else solutions = [angRad.toClone().setModulo(Trigo.pi(2)), Trigo.mesurePrincipale(Trigo.pi().am(angRad,true)).simplify().setModulo(Trigo.pi(2))]
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation {
					gauche:membreGauche
					droite:membreDroite
					modulo:"2k\\pi"
				}
			}]}
			new BSolutions {
				data:data
				bareme:100
				touches:["pi"]
				solutions:solutions
				moduloKey:"k"
			}
		]
