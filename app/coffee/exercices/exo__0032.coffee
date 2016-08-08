
Exercice.liste.push
	id:32
	title: "Mesure principale d'un angle"
	description: "La mesure d'un angle est donnée en radians. Il faut donner sa mesure principale."
	keyWords:["Géométrie", "Trigonométrie", "Seconde"]
	init: (data) ->
		inp = data.inputs
		if inp.d? then inp.d = Number inp.d
		else inp.d = Proba.aleaEntreBornes(6,20)*50
		ang = Trigo.degToRad inp.d
		p = Trigo.mesurePrincipale ang
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On donne l'angle $\\alpha = #{ang.tex()}$ en radians. Vous devez donner la mesure principale de cet angle.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Mesure principale"
				liste:[{tag:"$\\alpha$", name:"a", description:"Mesure principale de l'angle", good:p}]
				aide:oHelp.trigo.radian.concat(oHelp.trigo.pi, oHelp.trigo.mesure_principale)
				touches:["pi"]
			}
		]
