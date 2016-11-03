
Exercice.liste.push
	id:3
	title:"Symétrique d'un point"
	description:"Calculer les coordonnées du symétrique d'un point par rapport à un autre point."
	keyWords : ["Géométrie", "Repère", "Seconde"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[A] }).save(data.inputs)
		gAp = A.symetrique(B, "A'").simplify()

		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On se place dans un repère $(O;I,J)$.</p><p>On donne deux points $#{A.texLine()}$ et $#{B.texLine()}$.</p><p>Il faut déterminer les coordonnées de $A'$, symétrique de $A$ par rapport à $B$."}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Coordonnées de $A'$"
				liste:[{tag:"$x_{A'}$", name:"xAp", description:"Abscisse de A'", good:gAp.x}, {tag:"$y_{A'}$", name:"yAp", description:"Ordonnée de A'", good:gAp.y}]
				aide:oHelp.geometrie.analytique.symetrique
			}
		]
