
Exercice.liste.push
	id:1
	title:"Équation de droite"
	description:"Déterminer l'équation d'une droite passant par deux points."
	keyWords:["Géométrie", "Droite", "Équation", "Seconde"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[A] }).save(data.inputs)
		droite = mM.droite.par2pts A,B
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
					customVerif:(userObject, goodObject,verif_result)->
						if goodObject.toClone().inverse().equals(userObject) then verif_result.coeffDirecteur_inverse = true
					customTemplate: (verif_result) ->
						if verif_result.coeffDirecteur_inverse then ["Vous avez certainement fait le calcul $\\frac{x_B-x_A}{y_B-y_A}$ au lieu de $\\frac{y_B-y_A}{x_B-x_A}$."]
						else []
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
		data.A = A
		data.B = B
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
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre:"Dans tous les cas, donnez l'équation réduite de la droite $(AB)$."
				items: ("Points $#{item.A.texLine()}$ et $#{item.B.texLine()}$" for item in data)
				large:false
			}
		}


