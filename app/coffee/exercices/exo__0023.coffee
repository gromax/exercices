
Exercice.liste.push
	id:23
	title:"Équation de la tangente à une courbe"
	description:"Pour $x$ donné, on donne $f(x)$ et $f'(x)$. Il faut en déduire l'équation de la tangente à la courbe à l'abscisse $x$."
	keyWords:["Dérivation","Tangente","Équation","Première"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[ {axe:"x", coords:A} ] }).save(data.inputs)
		droite = mM.droite.par2pts A,B
		goodEq = droite.reduiteTex()
		xAtex = A.x.tex()
		yAtex = A.y.tex()
		der = droite.m().tex()
		data.values = { a:xAtex, y:yAtex, der:der}
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère une fonction une fonction $f$ dérivable sur $\\mathbb{R}$ et $\\mathcal{C}$ sa courbe représentative dans un repère.</p><p>On sait que $f\\left(#{xAtex}\\right) = #{yAtex}$ et $f'\\left(#{xAtex}\\right) = #{der}$.</p><p>Donnez l'équation de la tangente $\\mathcal{T}$ à la courbe $\\mathcal{C}$ en $x=#{xAtex}$."}]}
			new BListe {
				data:data
				bareme:100
				title:"Équation de la tangente $\\mathcal{T}$"
				liste:[{
					tag:"$y=$"
					name:"e"
					description:"Équation de la tangente"
					good:droite.reduiteObject()
					developp:true
					cor_prefix: "y="
					formes:"FRACTION"
				}]
				aide:oHelp.derivee.tangente
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Dans le(s) cas suivant(s), on considère une fonction $f$ et sa courbe. Pour une certaine valeur $a$, on donne $f(a)$ et $f'(a)$. Donnez la tangente à la courbe au point d'abscisse $a$."
				items: ("$a=#{item.values.a}$, $f(a)=#{item.values.y}$ et $f'(a)=#{item.values.der}$" for item in data)
				large:false
			}
		}
