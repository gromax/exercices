
Exercice.liste.push
	id:2
	title: "Milieu d'un segment"
	description: "Calculer les coordonnées du milieu d'un segment."
	keyWords:["Géométrie", "Repère", "Seconde"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		# Les deux points ne doivent pas être confondus
		while A.sameAs B
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		gM = A.milieu(B,"M")
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On se place dans un repère $(O;I,J)$</p><p>On donne deux points $#{A.texLine()}$ et $#{B.texLine()}$.</p><p>Il faut déterminer les coordonnées de $M$, milieu de $[AB]$."}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Coordonnées de $M$"
				liste:[{tag:"$x_M$", name:"xM", description:"Abscisse de M", good:gM.x}, {tag:"$y_M$", name:"yM", description:"Ordonnée de M", good:gM.y}]
				aide: oHelp.geometrie.analytique.milieu
			}
		]
