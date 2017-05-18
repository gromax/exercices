
Exercice.liste.push
	id:45
	title: "De la forme trigonométrique à la forme algébrique"
	description: "On vous donne un nombre complexe sous sa forme trigonométrique. vous devez trouver sa forme algébrique."
	keyWords:["Géométrie", "Complexe", "Première"]
	init: (data) ->
		# On choisit un argument parmi ceux dont les cos et sin sont connus
		inp = data.inputs
		if inp.a? then a = mM.toNumber inp.a
		else
			a = mM.alea.number mM.trigo.angles()
			inp.a = String a
		angleRad = mM.trigo.degToRad(a)
		if inp.m? then m = mM.toNumber inp.m
		else
			m = mM.alea.number {min:1, max:10}
			inp.m = String m
		data.tex = { m:m.tex(), a:angleRad.tex() }
		z = mM.trigo.complexe(m,a)
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Donnez $z$ sous sa <b>forme algébrique</b> $z = x+iy$ sachant que $|z|=#{m.tex()}$ et $Arg(z) = #{angleRad.tex()}$ <i>en radians</i></p>"}]}
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
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Dans chaque cas, connaissant $|z|$ et $arg(z)$ en radians, donnez la forme algébrique de $z$."
				items: ("$|z| = #{item.tex.m}$ et $arg(z) = #{item.tex.a}$" for item in data)
			}
		}
