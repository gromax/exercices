
Exercice.liste.push
	id:26
	title: "Coordonnées d'un vecteur"
	description: "Calculer les coordonnées du vecteur entre deux points."
	keyWords:["Géométrie", "Repère", "Vecteur", "Seconde"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs }).save(data.inputs)
		gAB = B.toClone("\\overrightarrow{AB}").am(A, true).simplify()
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:"<p>On se place dans un repère $(O;I,J)$</p><p>On donne deux points $#{A.texLine()}$ et $#{B.texLine()}$.</p><p>Il faut déterminer les coordonnées de $\\overrightarrow{AB}$.</p>"
			}]}
			new BListe {
				data:data
				bareme:100
				title:"Coordonnées de $\\overrightarrow{AB}$"
				liste:[{tag:"$x_{\\overrightarrow{AB}}$", name:"x", description:"Abscisse", good:gAB.x}, {tag:"$y_{\\overrightarrow{AB}}$", name:"y", description:"Ordonnée", good:gAB.y}]
				aide:oHelp.vecteur.coordonnes
			}
		]
