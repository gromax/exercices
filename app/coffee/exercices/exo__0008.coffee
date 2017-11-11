
Exercice.liste.push
	id:8
	title:"Image et antécédent avec une courbe"
	description:"La courbe d'une fonction étant donnée, il faut déterminer un antécédent et une image."
	keyWords:["Fonctions","Antécédent","Image","Seconde"]
	template:"2cols"
	max:10 # Définit la taille de la fenêtre graphique
	init: (data) ->
		max = @max
		decimals = 2
		inp = data.inputs
		# Initialisation du polynome
		poly = null
		if typeof inp.p isnt "undefined"
			poly = mM.polynome.make inp.p
			if not poly.isValid() then poly = null
		if poly is null
			# On crée un nouveau polynome
			points = ( {x:x*max, y:mM.alea.real({min:-60, max:60})*max/100 } for x in [-1, -.5, 0, .5, 1] )
			poly = mM.polynome.make { points:points, variable:"x"}
			inp.p = String(poly)
		# initialisation des images et antécédents à trouver
		h_init("xi",inp,-max,max) # x dont on demandera l'image
		h_init("xa",inp,-max,max) # x dont on calculera l'image afin de demander un antécédant
		h_init("xa",inp,-max,max,true) while inp.xa is inp.xi
		yi = mM.float poly, { x:inp.xi }
		ya = mM.float poly, { x:inp.xa }
		antecedents = mM.polynome.solve.numeric poly, { bornes:{min:-max, max:max}, decimals:decimals, y:ya }
		# Par l'effet des approximations, il est possible que xa ne soit pas détecté comme antécédent de ya
		data.values = { poly:poly, ya:ya, xi:inp.xi}
		# Création de l'objet graphiques
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-max,max,max,-max]}
			zone:"gauche"
			poly:poly
			customInit: ()->
				curve = @graph.create('functiongraph', [
					(x) -> mM.float @getAttribute('poly'), {x:x}
					-max, max],{strokeWidth:3, poly:@config.poly})
				@graph.create('point',[ -max, mM.float @config.poly, null, { x:-max} ],{fixed:true, fillColor:'blue', strokeColor:'blue', withlabel:false, size:4})
				@graph.create('point',[ max, mM.float @config.poly, null, { x:max} ],{fixed:true, fillColor:'blue', strokeColor:'blue', withlabel:false, size:4})
				@graph.create('glider',[-max/2,2,curve],{name:'M'})
			fcts:{
				solutions: (cor,inp,str_antecedents) ->
					# Dessin de la solution
					@graph.create('line',[[0,cor.ya],[1,cor.ya]], {color:'green',strokeWidth:2, fixed:true})
					if (cor.ya>0) then anchorY = 'top'
					else anchorY = 'bottom'
					for x,i in cor.antecedents
						@graph.create('line',[[x,cor.ya],[x,0]], {color:'green', straightFirst:false, straightLast:false, strokeWidth:2, dash:2, fixed:true})
						@graph.create('text',[x,0,str_antecedents[i]], {color:'green', anchorX:'middle', anchorY:anchorY})
					@graph.create('line',[[inp.xi,0],[inp.xi,cor.yi]], {color:'orange', straightFirst:false, straightLast:false, strokeWidth:2, dash:2, fixed:true})
					@graph.create('line',[[inp.xi,cor.yi],[0,cor.yi]], {color:'orange', straightFirst:false, straightLast:false, strokeWidth:2, dash:2, fixed:true})
					if (inp.xi>0) then anchorX = 'right'
					else anchorX = 'left'
					@graph.create('text',[0,cor.yi,numToStr(cor.yi,1)], {color:'orange', anchorX:anchorX, anchorY:'middle'})
			}
		}

		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On considère la fonction $f$ définie sur $[#{-max};#{max}]$ dont la courbe est donnée ci-contre.</p><p>Vous pouvez déplacer le point $M$ sur la courbe afin d'obtenir une meilleure lecture des coordonnées.</p>"}
				]
			}
			graphContainer
			new Brique {
				data:data
				bareme:100
				zone:"droite"
				needed:["i","a"]
				graphContainer:graphContainer
				precision:.2
				good: { antecedents:antecedents, yi:yi, ya:ya}
				title: "Image et antécédent"
				focus:"i"
				customAskTemplate : -> {
					title:@title
					templateName:"std_panel"
					focus:true
					zones:[
						{
							body:"texte"
							html:"Donnez l'image de #{numToStr inp.xi} et <b>un</b> antécédent de #{numToStr @good.ya, 1} à ±#{numToStr @precision}"
						}, {
							body:"champ"
							html:Handlebars.templates.std_form {
								id:"form#{@divId}"
								inputs:[
									{tag:"Image de #{numToStr inp.xi}", description:"Valeur décimale", name:"i", large:true}
									{tag:"Antécédent de #{numToStr @good.ya, 1}", description:"Valeur décimale", name:"a", large:true}
								]
							}
						}
					]
				}
				customVerif: () ->
					cor = @good
					inp = @data.inputs
					str_antecedents = (numToStr(x,1) for x in cor.antecedents)

					messages = []
					# image
					color="error"
					message = "<b>Image de #{numToStr inp.xi} :</b> Vous avez répondu <b>#{ pointToComma(@data.answers.i) }</b>."
					if isRealApproxIn([cor.yi],@data.answers.i,@precision) isnt false
						message+=" Bonne réponse."
						color="ok"
						@data.note += @bareme/2
					else
						message+=" La bonne réponse était #{numToStr cor.yi, 1}."
					messages.push { color:color, text:message+" La construction graphique est donnée en orange."}
					# antecedent
					color="error"
					message = "<b>Antécédent de #{numToStr cor.ya, 1} :</b> Vous avez répondu <b>#{ pointToComma(@data.answers.a) }</b>."
					if isRealApproxIn(cor.antecedents,@data.answers.a,@precision) isnt false
						color="ok"
						message+=" Bonne réponse."
						@data.note += @bareme/2
					else
						if cor.antecedents.length is 1 then message+= " La bonne était #{str_antecedents}."
						else message+= " Les bonnes réponses possibles étaient : <b>#{str_antecedents.join("</b> ; <b>")}</b>."
					messages.push { color:color, text:message+" La construction graphique est donnée en vert."}
					# tracé de la solution
					@graphContainer.solutions(cor,inp,str_antecedents)
					# sortie des zones pour le template
					[{
						list:"correction"
						html:Handlebars.templates.listItem messages
					}]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itemData,i in data
			courbe = { color:"blue", expr:itemData.values.poly.toClone().simplify().toString().replace(/,/g,'.').replace(/x/g,'(\\x)') }
			xi = itemData.values.xi
			ya = itemData.values.ya
			questions = Handlebars.templates["tex_enumerate"] { items:["Donnez l'image de #{xi}", "Donnez le(s) antécédent(s) de #{ya}"] }
			# Calcul de la taille
			graphique = Handlebars.templates["tex_courbes"] { index:i+1, max:@max, courbes:[ courbe ], scale:.4*@max/10 }
			out.push {
				title:@title
				contents: [graphique, questions]
			}
		out
