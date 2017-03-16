
Exercice.liste.push
	id:33
	title:"Équation modulo $2\\pi$"
	description:"Résoudre une équation portant sur des mesures angulaires en radians, avec un terme $2k\\pi$."
	keyWords:["Trigonométrie","Algèbre","Équation","Première"]
	init: (data) ->
		inp = data.inputs
		if inp.a? then a = Number inp.a
		else a = inp.a = mM.alea.real { min:1, max:5 }
		if inp.b? then b= Number inp.b
		else b = inp.b = mM.alea.real { min:1, max:5, no:[a] }
		a = mM.toNumber a
		b = mM.toNumber b
		if inp.ang1? then ang1= mM.toNumber inp.ang1
		else
			ang1 = mM.alea.number { values:{min:1, max:6}, sign:true, coeff:30}
			inp.ang1 = String ang1
		ang1 = mM.trigo.degToRad ang1
		if inp.ang2? then ang2= mM.toNumber inp.ang2
		else
			ang2 = mM.alea.number { values:{min:1, max:6}, sign:true, coeff:30 }
			inp.ang2 = String ang2
		ang2 = mM.trigo.degToRad ang2

		membreGaucheTex = mM.exec([ "x", a, "*", ang1, "+"], {simplify:true}).tex()
		membreDroiteTex = mM.exec([ "x", b, "*", ang2, "+", 2, "#", "pi", "*", "*", "+"], {simplify:true}).tex()

		[
			new BEnonce { zones:[{
				body:"enonce"
				html:Handlebars.templates.equation { gauche:membreGaucheTex, droite:membreDroiteTex }
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
					solutions:[ mM.exec([ang2, ang1, "-", 2, "#", "pi", "*", "*", "+", a, b, "-", "/"], { simplify:true, developp:true, modulo:true}) ]
					moduloKey: "k"
				}]
			}
		]
