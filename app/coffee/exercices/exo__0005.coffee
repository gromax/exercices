
Exercice.liste.push
	id:5
	title:"Distance entre deux points"
	description:"Dans un repère orthonormé, calculer la distance entre deux points."
	keyWords:["Géométrie", "Repère", "Seconde"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[A] }).save(data.inputs)
		gAB = A.toClone().minus(B).norme()
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On se place dans un repère $(O;I,J)$</p><p>On donne deux points $#{A.texLine()}$ et $#{B.texLine()}$.</p><p>Il faut déterminer la valeur exacte de la distance $AB$."}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Distance $AB$"
				liste:[{tag:"$AB$", name:"AB", description:"Distance AB", good:gAB}]
				aide: oHelp.geometrie.analytique.distance.concat oHelp.interface.sqrt
				touches:["sqrt"]
			}
		]
