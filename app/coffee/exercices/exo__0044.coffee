
Exercice.liste.push
	id:44
	title: "De la forme algébrique à la forme trigonométrique"
	description: "On vous donne un nombre complexe sous sa forme algébrique. vous devez trouver sa forme trigonométrique, c'est à dire son module et son argument."
	keyWords:["Géométrie", "Complexe", "Première"]
	init: (data) ->
		# On choisit un argument parmi ceux dont les cos et sin sont connus
		inp = data.inputs
		if inp.a? then a=Number inp.a
		else inp.a = a = Proba.aleaIn Trigo.anglesConnus()
		a = Trigo.degToRad(a)
		if inp.m? then m=Number inp.m
		else inp.m = m = Proba.aleaEntreBornes(1,10)
		m = NumberManager.makeNumber m
		z = Trigo.complexe(m,a)
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Donnez le module et l'argument de $z=#{z.tex()}$.</p><p><i>Donnez l'argument $\\theta$ en radians et en valeur principale, c'est à dire $-\\pi<\\theta\\leqslant \\pi$</i></p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Forme trigonométrique"
				liste:[
					{tag:"$|z|$", name:"m", description:"Module de z", good:m},
					{tag:"$\\theta$", name:"a", description:"Argument de z", good:a},
				]
				aide: oHelp.complexes.argument.concat oHelp.complexes.module
				touches:["pi"]
			}
		]
