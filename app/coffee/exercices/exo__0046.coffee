
Exercice.liste.push
	id:46
	title: "Calcul d'un angle avec les complexes"
	description: "Trois points A,B et C sont donnés. Il faut trouver l'angle $\\widehat{BAC}$."
	keyWords:["Géométrie", "Complexe", "Première"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		C = Vector.makeRandom "C", data.inputs
		# A et B ne doivent pas être confondus
		while A.sameAs B
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		# A et C ne doivent pas être confondus
		while A.sameAs C
			C = Vector.makeRandom "C", data.inputs, { overwrite:true }
		zA = A.affixe()
		zB = B.affixe()
		zC = C.affixe()
		zAB = zB.toClone().am(zA,true)
		zAC = zC.toClone().am(zA,true)
		z = zAB.toClone().conjugue().md(zAC,false)
		ang = z.arg(false)
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On donne $A$ d'affixe $z_A=#{zA.tex()}$, $B$ d'affixe $z_B=#{zB.tex()}$ et $C$ d'affixe $z_C=#{zC.tex()}$.</p><p>On notera $z_1$ l'affixe de $\\overrightarrow{AC}$ et $z_2$ l'affixe de $\\overrightarrow{AB}$"}]}
			new BListe {
				data:data
				bareme:30
				title:"Affixe des vecteurs"
				liste:[
					{tag:"$z_1$", name:"z1", description:"Affixe de AC", good:zAC}
					{tag:"$z_2$", name:"z2", description:"Affixe de AB", good:zAB}
				]
				aide: oHelp.complexes.affixeVecteur
			}
			new BListe {
				data:data
				bareme:30
				title:"$z=z_1\\cdot\\overline{z_2}$", text:"Calculez le produit $z=z_1\\cdot\\overline{z_2}$"
				liste:[
					{tag:"$z$", name:"z", description:"Forme x+iy", good:z}
				]
			}
			new BListe {
				data:data
				bareme:40
				title:"Angle $\\widehat{BAC}$"
				text:"L'angle que l'on cherche est l'argument de $z$. Donnez une approximation à 1° près de cet angle en degrés."
				liste:[
					{tag:"$\\widehat{BAC}$", name:"a", description:"Angle = Argument de z", good:ang, params:{ arrondi:0 }}
				]
				aide: oHelp.complexes.argument
			}
		]
