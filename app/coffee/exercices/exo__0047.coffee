﻿
Exercice.liste.push
	id:47
	title: "Calcul de l'aire d'un parallélogramme avec les complexes"
	description: "Quatre points A, B, D sont donnés. On sait que $ABCD$ est un parallélogramme. Il faut trouver l'aire de $ABCD$."
	keyWords:["Géométrie", "Complexe", "Première"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		D = Vector.makeRandom "D", data.inputs
		# A et B ne doivent pas être confondus
		while A.sameAs B
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		# A et D ne doivent pas être confondus
		while A.sameAs D
			D = Vector.makeRandom "D", data.inputs, { overwrite:true }
		zA = A.affixe()
		zB = B.affixe()
		zD = D.affixe()
		zAB = zB.toClone().am(zA,true)
		zAD = zD.toClone().am(zA,true)
		z = zAB.toClone().conjugue().md(zAD,false)
		aire = z.getImag().toClone().abs()
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On donne $A$ d'affixe $z_A=#{zA.tex()}$, $B$ d'affixe $z_B=#{zB.tex()}$ et $D$ d'affixe $z_D=#{zD.tex()}$.</p><p>Le point $C$ est tel que $ABCD$ est un parallélogramme (pas besoin de savoir l'affixe de $C$)</p><p>On notera $z_1$ l'affixe de $\\overrightarrow{AD}$ et $z_2$ l'affixe de $\\overrightarrow{AB}$"}]}
			new BListe {
				data:data
				bareme:40
				title:"Affixe des vecteurs"
				liste:[
					{tag:"$z_1$", name:"z1", description:"Affixe de AD", good:zAD}
					{tag:"$z_2$", name:"z2", description:"Affixe de AB", good:zAB}
				]
				aide: oHelp.complexes.affixeVecteur
			}
			new BListe {
				data:data
				bareme:40
				title:"$z=z_1\\cdot\\overline{z_2}$"
				text:"Calculez le produit $z=z_1\\cdot\\overline{z_2}$"
				liste:[
					{tag:"$z$", name:"z", description:"Forme x+iy", good:z}
				]
			}
			new BListe {
				data:data
				bareme:20
				title:"Aire de $ABCD$"
				text:"On peut prouver que l'aire recherchée est la valeur absolue de la partie imaginaire de $z$."
				liste:[
					{tag:"Aire de $ABCD$", name:"a", description:"Aire = |Im(z)|", good:aire}
				]
				aide: oHelp.complexes.aire_plg
			}
		]
