
Exercice.liste.push
	id:23
	title:"Équation de la tangente à une courbe"
	description:"Pour $x$ donné, on donne $f(x)$ et $f'(x)$. Il faut en déduire l'équation de la tangente à la courbe à l'abscisse $x$."
	keyWords:["Dérivation","Tangente","Équation","Première"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		# Les deux abscisses doivent être différentes
		while A.sameAs B,"x"
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		droite = Droite2D.par2Pts A,B
		goodEq = droite.reduiteTex()
		xAtex = A.x.tex()
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère une fonction une fonction $f$ dérivable sur $\\mathbb{R}$ et $\\mathcal{C}$ sa courbe représentative dans un repère.</p><p>On sait que $f\\left(#{xAtex}\\right) = #{A.y.tex()}$ et $f'\\left(#{xAtex}\\right) = #{droite.m().tex()}$.</p><p>Donnez l'équation de la tangente $\\mathcal{T}$ à la courbe $\\mathcal{C}$ en $x=#{xAtex}$."}]}
			new BListe {
				data:data
				bareme:100
				title:"Équation de la tangente $\\mathcal{T}$"
				liste:[{tag:"$y=$", name:"e", description:"Équation de la tangente", good:droite.reduiteObject(), params:{developp:true, formes:"FRACTION", cor_prefix:"y="}}]
				aide:oHelp.derivee.tangente
			}
		]
