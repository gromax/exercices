
Exercice.liste.push
	id:4
	title:"Quatrième point d'un parallélogramme"
	description:"Connaissant trois points, calculer les coordonnées d'un quatrième point pour former un parallélogramme."
	keyWords: ["Géométrie", "Repère", "Seconde"]
	init: (data) ->
		i=data.inputs
		A = mM.alea.vector({ name:"A", def:i }).save(i)
		B = mM.alea.vector({ name:"B", def:i, forbidden:[A] }).save(i)
		C = mM.alea.vector({ name:"C", def:i, forbidden:[{aligned:[A,B]}] }).save(i)
		data.good = A.toClone("D").minus(B).plus(C)
		data.ABDC = B.toClone("D'").minus(A).plus(C)
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On se place dans un repère $(O;I,J)$</p><p>On donne trois points $#{A.texLine()}$, $#{B.texLine()}$ et $#{C.texLine()}$.</p><p>Il faut déterminer les coordonnées du point $D$ pour que $ABCD$ soit un parallélogramme."}
				]
			}
			new BListe {
				data:data
				bareme:100
				needed:["x","y"]
				title:"Coordonnées de $D$"
				liste:[
					{tag:"$x_D$", description:"Abscisse de D", name:"x"}
					{tag:"$y_D$", description:"Ordonnée de D", name:"y"}
				]
				aide:{template:"help", plg:true}
				ver: () ->
					uD = mM.vector "D", {x:@a.x, y:@a.y}
					# message de correction par défaut
					out = [
						{ text: "Vous avez répondu $#{uD.texLine()}$." }
						{ text:"La bonne réponse était $#{@data.good.texLine()}$."}
					]
					switch
						when uD.sameAs @data.good
							@data.note = @bareme
							out = [ { text: "Vous avez répondu $#{uD.texLine()}$. Bonne réponse.", color:"ok"} ]
						when uD.sameAs @data.ABDC
							@data.note = @bareme/2
							out.push { text:"Avec vos coordonnées, c'est $ABDC$ qui est un parallélogramme.", color:"error"}
						when (uD.sameAs @data.good, "x") or (uD.sameAs @data.good, "y")
							@data.note = @bareme/2
					@container.html Handlebars.templates.std_panel {
						title:@config.title
						zones:[{
							list:"correction"
							html:Handlebars.templates.listItem out
						}]
					}
			}
		]
