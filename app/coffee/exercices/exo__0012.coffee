
Exercice.liste.push
	id:12
	title:"Tracer la courbe d'une fonction affine"
	description:"L'expression d'une fonction affine étant donnée, il faut tracer sa courbe dans un repère."
	keyWords:["Analyse","Fonction","Courbe","Affine","Seconde"]
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
			new BEnonce { zones:[ {body:"enonce", html:"<p>On considère la fonction affine $#{droite.affineTex("f","x")}$.</p><p>Placez les points $A$ et $B$ de sorte que $(AB)$ soit la courbe représentative de la fonction.</p>"}]}
			graphContainer
			new BPoints {
				data:data
				bareme:100
				zone:"droite"
				max:max
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
