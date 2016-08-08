
Exercice.liste.push
	id:18
	title:"Tracer la courbe d'une fonction $x\\mapsto |ax+b|$"
	description:"On donne l'expression d'une fonction affine avec une valeur absolue. Il faut tracer sa courbe représentative."
	keyWords:["Analyse","Fonction","Courbe","Affine","Seconde"]
	template:"2cols"
	init: (data) ->
		max = 10
		inp = data.inputs
		ans = data.answers
		A = data.A = Vector.makeRandom "A", inp, {ext:[[-max, max], [1,max]]}
		B = data.B = Vector.makeRandom "B", inp, {ext:[[-max, max], [-max,-1]]}
		# Les deux points ne doivent pas avoir la même abscisse
		while A.sameAs B,"x"
			B = Vector.makeRandom "B", inp, { overwrite:true, ext:[[-max, max], [-max,-1]]}
		droite = data.droite = Droite2D.par2Pts A,B
		# Liste des points à tracer
		pts = [
			{name:"A", user:{x:ans.xA, y:ans.yA}, def:{x:-max+1, y:max-1}}
			{name:"B", user:{x:ans.xB, y:ans.yB}, def:{x:0, y:-max+1}}
			{name:"C", user:{x:ans.xC, y:ans.yC}, def:{x:max-1, y:max-1}}
		]
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-max,max,max,-max]}
			zone:"gauche"
			pts:pts
			customInit: ()->
				@points = ( @addPoint(pt.name, pt.user, pt.def) for pt in @config.pts )
				@graph.create('line',["A","B"], {strokeColor:'#00ff00',strokeWidth:2, straightLast:false })
				@graph.create('line',["B","C"], {strokeColor:'#00ff00',strokeWidth:2, straightFirst:false})
				@graph.on 'move', () =>
					if @points[0].X()>@points[1].X()-.1 then @points[0].moveTo([@points[1].X()-.1, @points[0].Y()])
					if @points[2].X()<@points[1].X()+.1 then @points[2].moveTo([@points[1].X()+.1, @points[2].Y()])
		}
		[
			new BEnonce {
				zone:"droite"
				zones:[
					{body:"enonce", html:"<p>Dans le repère ci-contre, on vous demande de tracer la courbe de la fonction $f:x\\mapsto\\left|#{droite.reduiteObject().tex()}\\right|$ en ajustant la position des points $A$, $B$ et $C$.</p>"}
				]
			}
			graphContainer
			new BPoints {
				data:data
				bareme:100
				graphContainer:graphContainer
				max:max
				dmax:.2
				zone:"droite"
				verif_point:(p)->
					x=p.X()
					y=p.Y()
					if @data.droite.float_y(x)>0 then d = @data.droite.float_distance(x,y)
					else d = @data.droite.float_distance(x,-y)
					if d<@config.dmax
						output = { user: p.name }
						# Le point est assez près
						unless d is 0 then output.approx = true
					else
						output = { good: p.name }
					output
				eg: () ->
					y1 = Math.abs(@data.droite.float_y(-@config.max))
					y2 = Math.abs(@data.droite.float_y(@config.max))
					x0 = @data.droite.float_x(0)
					@config.graphContainer.graph.create('line',[[-@config.max,y1],[x0,0]], {strokeColor:'blue',strokeWidth:2,fixed:true, straightLast:false})
					@config.graphContainer.graph.create('line',[[x0,0],[@config.max,y2]], {strokeColor:'blue',strokeWidth:2,fixed:true, straightFirst:false})
					@config.graphContainer.graph.create('line',[[@data.A.x.toNumber(),@data.A.y.toNumber()],[@data.B.x.toNumber(),@data.B.y.toNumber()]], {strokeColor:'blue',strokeWidth:1,fixed:true,dash:2})
			}
		]
