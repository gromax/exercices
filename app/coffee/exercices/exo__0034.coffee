
Exercice.liste.push
	id:34
	title:"Équation de type $\\cos x = \\cos \\alpha$"
	description:"Résoudre une équation de la forme $\\cos x = \\cos \\alpha$ $\\sin x = \\sin \\alpha$."
	keyWords:["Trigonométrie","Algèbre","Équation","Première"]
	init: (data) ->
		inp = data.inputs
		if inp.ang? then ang= Number inp.ang
		else inp.ang = ang = 15*mM.alea.real { min:1, max:12, sign:true }
		if inp.type? then type=inp.type # sin ou cos
		else inp.type = type = mM.alea.in ["cos","sin"]
		angRad = mM.trigo.degToRad [ ang ]
		if type is "cos"
			membreGauche = mM.exec([ "x", "cos"]).tex()
			membreDroite = mM.exec([angRad, "cos"]).tex()
			if (Math.abs(ang) % 180) is 0 then solutions = [ mM.exec([angRad, 2, "pi", "*", "modulo"]) ]
			else solutions = [
				mM.exec([ angRad, 2, "pi", "*", "modulo"])
				mM.exec([ angRad, "*-", 2, "pi", "*", "modulo"])
			]
		else
			membreGauche = mM.exec([ "x", "sin"]).tex()
			membreDroite = mM.exec([ angRad, "sin"]).tex()
			if ((Math.abs(ang)+90)%180) is 0 then solutions = [ mM.exec([angRad, 2, "pi", "*", "modulo"]) ]
			else solutions = [
				mM.exec([angRad, 2, "pi", "*", "modulo"])
				mM.exec(["pi", angRad, "-", 2, "#", "pi", "*", "*", "+"], {simplify:true, modulo:true})
			]
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation {
					gauche:membreGauche
					droite:membreDroite
					modulo:"2k\\pi"
				}
			}]}
			new BListe {
				title:"Solutions"
				data:data
				bareme:100
				touches:["empty","pi"]
				liste:[{
					name:"solutions"
					tag:"$\\mathcal{S}$"
					large:true
					solutions:solutions
					moduloKey:"k"
				}]
			}
		]
