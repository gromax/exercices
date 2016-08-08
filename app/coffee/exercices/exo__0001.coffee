
Exercice.liste.push
	id:1
	title:"Équation de droite"
	description:"Déterminer l'équation d'une droite passant par deux points."
	keyWords:["Géométrie", "Droite", "Équation", "Seconde"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		# Les deux points ne doivent pas être confondus
		while A.sameAs B
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		droite = Droite2D.par2Pts A,B
		verticale = droite.verticale()

		if verticale then lastStage = new BListe {
			pretitle:"Équation"
			title:"Valeurs de $a$"
			data:data
			bareme:80
			liste:[
				{tag:"$a$", name:"a", description:"Valeur de a", good:droite.k() }
			]
			aide:oHelp.droite.equation_reduite.verticale
		}
		else lastStage = new BListe {
			pretitle:"Équation"
			title:"Valeurs de $m$ et $p$"
			data:data
			bareme:80
			liste:[
				{
					tag:"$m$"
					name:"m"
					description:"Valeur de m"
					good:droite.m()
					params:
						custom:(output)->
							if NumberManager.equal(output.goodObject.toClone().inverse(), output.userObject) then output.coeffDirecteur_inverse = true
						customTemplate:true
				}
				{
					tag:"$p$"
					name:"p"
					description:"Valeur de p"
					good:droite.p()
				}
			]
			aide:oHelp.droite.equation_reduite.oblique
		}

		[
			new BEnonce {
				zones:[{
					body:"enonce"
					html:"<p>On se place dans un repère orthogonal $(O;I,J)$</p><p>On donne deux points $#{A.texLine()}$ et $#{B.texLine()}$.</p><p>Il faut déterminer l'équation réduite de la droite $(AB)$.</p>"
				}]
			}
			new BChoixMultiple {
				data:data
				bareme:20
				aKey:"v"
				title:"Forme de l'équation réduite"
				choix: ["$x=a$", "$y=mx+p$"]
				good: if verticale then 0 else 1
				correction: if verticale then ["$x_A = x_B$, c'est donc une équation de la forme $x= a$"] else ["$x_A \\neq x_B$, c'est donc une équation de la forme $y=m x + p$"]
				aide:oHelp.droite.equation_reduite.type
			}
			lastStage
		]


