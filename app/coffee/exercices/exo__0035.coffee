
Exercice.liste.push
	id:35
	title:"Équation de type $\\cos (a\\cdot x+b) = \\cos \\alpha$"
	description:"Résoudre une équation de la forme $\\cos x = \\cos \\alpha$ $\\sin x = \\sin \\alpha$."
	keyWords:["Trigonométrie","Algèbre","Équation","Première"]
	init: (data) ->
		inp = data.inputs
		if inp.a? then a= Number inp.a
		else
			a = mM.alea.number { min:2, max:5 }
			inp.a = String a
		if inp.ang1? then ang1 = mM.toNumber inp.ang1
		else
			ang1 = mM.alea.number { min:1, max:6, sign:true, coeff:30 }
			inp.ang1 = String ang1
		ang1 = mM.trigo.degToRad ang1
		if inp.ang2? then ang2 = mM.toNumber inp.ang2
		else
			ang2 = mM.alea.number { min:1, max:6, sign:true, coeff:30 }
			inp.ang2 = String ang2
		ang2 = mM.trigo.degToRad ang2
		if inp.type? then type=inp.type
		else inp.type = type = mM.alea.real ["cos","sin"]

		membreGauche = mM.exec(["x", a, "*", ang1, "+", type], {simplify:true}).tex()
		membreDroite = mM.exec([ang2, type]).tex()

		modulo = mM.exec [2, "pi", "*", a, "/"], {simplify:true}
		ang = mM.exec [ang2, ang1, "-", a, "/"], {simplify:true}
		if type is "cos"
			solutions = [ang.toClone().setModulo(modulo), ang.opposite().setModulo(modulo)]
		else
			solutions = [ang.toClone().setModulo(modulo), mM.trigo.principale(["pi", ang, "-"]).setModulo(modulo)]
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation {
					gauche:membreGauche
					droite:membreDroite
					modulo:"\\frac{2k\\pi}{#{inp.a}}"
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
				}]
			}
		]
