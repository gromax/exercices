
Exercice.liste.push
	id:13
	title:"Tracer une droite dont on connaît l'équation réduite"
	description:"On donne l'équation réduite d'une droite. Il faut tracer cette droite."
	keyWords:["Géométrie","Droite","Équation","Seconde"]
	template:"2cols"
	init: (data) ->
		max = 10
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		# Les deux points ne doivent pas avoir la même abscisse
		while A.sameAs B,"x"
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		droite = data.droite = Droite2D.par2Pts A,B
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-max,max,max,-max]}
			zone:"gauche"
			pts:[
				{x:data.answers.xA, y:data.answers.yA }
				{x:data.answers.xB, y:data.answers.yB }
			]
			customInit: ()->
				pA = @addPoint "A", @config.pts[0], {x:-8, y:-3}
				pB = @addPoint "B", @config.pts[1], {x:8, y:-3}
				AB = @graph.create('line',["A","B"], {strokeColor:'#00ff00',strokeWidth:2})
				@points = [pA,pB]
		}
		[
			new BEnonce {zones:[ {body:"enonce", html:"<p>On considère la droite $\\mathcal{D}$ d'équation réduite $#{droite.reduiteTex()}$.</p><p>Placez les points $A$ et $B$ de sorte que $(AB) = \\mathcal{D}$.</p>"}]}
			graphContainer
			new BPoints {
				data:data
				bareme:100
				max:max
				zone:"droite"
				graphContainer:graphContainer
				dmax:.2
				verif_point:(p)->
					x=p.X()
					y=p.Y()
					d = @data.droite.float_distance(x,y)
					if d<@config.dmax
						# Le point est assez près
						output = { user: p.name+"(#{x.toStr 2};#{y.toStr 2})" }
						unless d is 0 then output.approx = true
					else
						output = { good: p.name }
					output
				eg: () ->
					# trace la courbe juste s'il y a une erreur
					@config.graphContainer.graph.create('line',@data.droite.float_2_points(@config.max), {strokeColor:'blue',strokeWidth:2,fixed:true})
			}
		]
