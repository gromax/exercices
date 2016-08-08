
Exercice.liste.push
	id:45
	title: "De la forme trigonométrique à la forme algébrique"
	description: "On vous donne un nombre complexe sous sa forme trigonométrique. vous devez trouver sa forme algébrique."
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
			new BEnonce {zones:[{body:"enonce", html:"<p>Donnez $z$ sous sa <b>forme algébrique</b> $z = x+iy$ sachant que $|z|=#{m.tex()}$ et $Arg(z) = #{a.tex()}$ <i>en radians</i></p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Forme algébrique"
				text:"<i>Attention, si vous écrivez $i\\sqrt{\\cdots}$, mettez une espace : i sqrt(...) ou le signe de multiplication : i*sqrt(...)</i>"
				liste:[
					{tag:"$z$", name:"z", description:"Forme x+iy", good:z}
				]
				aide: oHelp.complexes.trigo_alg
				touches:["sqrt"]
			}
		]
