
Exercice.liste.push
	id:5
	title:"Distance entre deux points"
	description:"Dans un repère orthonormé, calculer la distance entre deux points."
	keyWords:["Géométrie", "Repère", "Seconde"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		# Les deux points ne doivent pas être confondus
		while A.sameAs B
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		gAB = A.toClone().am(B,true).norme()
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
