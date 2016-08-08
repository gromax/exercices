
Exercice.liste.push
	id:4
	title:"Quatrième point d'un parallélogramme"
	description:"Connaissant trois points, calculer les coordonnées d'un quatrième point pour former un parallélogramme."
	keyWords: ["Géométrie", "Repère", "Seconde"]
	init: (data) ->
		i=data.inputs
		A = Vector.makeRandom "A", i
		B = Vector.makeRandom "B", i
		# Les deux points ne doivent pas être confondus
		while A.sameAs B
			B = Vector.makeRandom "B", i, { overwrite:true }
		C = Vector.makeRandom "C", i
		# Les trois points ne doivent pas être alignés
		while A.aligned B, C
			C = Vector.makeRandom "C", i, { overwrite:true }
		data.good = A.toClone("D").am(B,true).am(C,false)
		data.ABDC = B.toClone("D'").am(A,true).am(C,false)
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On se place dans un repère $(O;I,J)$</p><p>On donne trois points $#{A.texLine()}$, $#{B.texLine()}$ et $#{C.texLine()}$.</p><p>Il faut déterminer les coordonnées du point $D$ pour que $ABCD$ soit un parallélogramme."}
				]
			}
			new Brique {
				data:data
				bareme:100
				needed:["x","y"]
				title:"Coordonnées de $D$"
				ask: () ->
					@helper_disp_inputs(@title,null,[{tag:"$x_D$", description:"Abscisse de D", name:"x"}, {tag:"$y_D$", description:"Ordonnée de D", name:"y"}],{template:"help", plg:true},null)
				ver: () ->
					uD = new Vector "D", {x:@a.x, y:@a.y}
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
						title:@title
						zones:[{
							list:"correction"
							html:Handlebars.templates.listItem out
						}]
					}
			}
		]
