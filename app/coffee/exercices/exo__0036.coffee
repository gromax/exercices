
Exercice.liste.push
	id:36
	title:"Placer des points sur le cercle trigonométrique"
	description:"Placer sur le cercle trigonométrique le point correspondant à une mesure donnée en radians."
	keyWords:["Trigonométrie", "Première", "Radians", "Seconde"]
	template:"2cols"
	init: (data) ->
		if data.inputs.deg? then deg = mM.toNumber data.inputs.deg
		else
			deg = mM.alea.number { min:3, max:8, sign:true, coeff:[30,45] }
			data.inputs.deg = String deg
		ang = mM.trigo.degToRad deg
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-1.5,1.5,1.5,-1.5]}
			zone:"gauche"
			customInit: ()->
				circle = @graph.create("circle", [[0,0],1],{fixed:true, strokeColor:'red'})
				@M = @graph.create("glider", [circle],{name:"M", fixed:false, size:4, color:'blue', showInfoBox:true})
			fcts:{
				correcOk: (rad)->
					@graph.removeObject @M
					@graph.create("point", [Math.cos(rad), Math.sin(rad)],{name:"M", fixed:true, size:4, color:'green'})
				correcNOk: (radU,radG)->
					@graph.removeObject @M
					@graph.create("point", [Math.cos(radU), Math.sin(radU)],{name:"", fixed:true, size:4, color:'red'})
					@graph.create("point", [Math.cos(radG), Math.sin(radG)],{name:"M", fixed:true, size:4, color:'green'})
			}
		}

		[
			new BEnonce {
				zone:"droite"
				zones:[{body:"enonce", html:"<p>Vous devez placer sur le cercle le point $M$ correspondant à la mesure $#{ang.tex()}$ en radians.</p>"}]
			}
			graphContainer
			new Brique {
				data:data
				bareme:100
				needed:["a"]
				graphContainer:graphContainer
				good:deg
				zone:"droite"
				waitingTemplate:"std_valid_when_finished"
				customFormValidation: (event) ->
					@data.answers.a = Math.round (Math.acos @graphContainer.M.X())*180/Math.PI
					if @graphContainer.M.Y()<0 then @data.answers.a *= -1
					true
				customVerif: () ->
					user = Number @data.answers.a
					radUser = user*Math.PI/180
					ecart = Math.abs(@good-user)
					ecart-=360 while ecart>=355
					ok = (Math.abs(ecart)<=5)
					if ok
						@graphContainer.correcOk(radUser)
						@data.note = @bareme
						correc = [{ color:"ok", text:"Point $M$ bien placé."}]
					else
						rd = @good*Math.PI/180
						@graphContainer.correcNOk(radUser,rd)
						correc = [{ text:"Point $M$ mal placé.", color:"error"}]
					[{
						list:"correction"
						html:Handlebars.templates.listItem correc
					}]
			}
		]
