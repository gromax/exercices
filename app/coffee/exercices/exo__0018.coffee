
Exercice.liste.push
	id:18
	title:"Tracer la courbe d'une fonction $x\\mapsto |ax+b|$"
	description:"On donne l'expression d'une fonction affine avec une valeur absolue. Il faut tracer sa courbe représentative."
	keyWords:["Analyse","Fonction","Courbe","Affine","Seconde"]
	template:"2cols"
	init: (data) ->
		max = 12
		inp = data.inputs
		ans = data.answers
		if (inp.xA? and inp.xB and inp.yA? and inp.yB)
			A = data.A = mM.vector("A", {x:inp.xA, y:inp.yA})
			B = data.B = mM.vector("B", {x:inp.xB, y:inp.yB})
		else
			# Je tire au hasard un coeff directeur qui tombe bien
			# pour éviter les fractions trop compliquées
			{a,b} = mM.alea.in [
				{a:1, b:1}
				{a:1, b:2}
				{a:1, b:3}
				{a:2, b:3}
				{a:2, b:5}
				{a:3, b:5}
			]
			# On choisit au hasard d'inverser x et y
			if mM.alea.dice(1,2)
				dx = a
				dy = b
			else
				dx = b
				dy = a
			# On choisit au hasard un point un sens croissant ou décroissant
			if mM.alea.dice(1,2) then dy *= -1
			# On choisit un point 0 (celui où on touche l'axe)
			x0 = mM.alea.real {min:-max+dx, max:max-dx}
			A = data.A = mM.vector("A", {x:x0-dx, y:-dy}).save(data.inputs)
			B = data.B = mM.vector("B", {x:x0+dx, y:dy}).save(data.inputs)
		droite = data.droite = mM.droite.par2pts A,B
		# Liste des points à tracer
		pts = [
			{name:"A", user:{x:ans.xA, y:ans.yA}, def:{x:-max+1, y:max-1}}
			{name:"B", user:{x:ans.xB, y:ans.yB}, def:{x:0, y:0}}
			{name:"C", user:{x:ans.xC, y:ans.yC}, def:{x:max-1, y:max-1}}
		]
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-max,2*max-3,max,-3]}
			zone:"gauche"
			pts:pts
			customInit: ()->
				@points = ( @addPoint(pt.name, pt.user, pt.def) for pt in @config.pts )
				@graph.create('line',["A","B"], {strokeColor:'#00ff00',strokeWidth:2, straightLast:false })
				@graph.create('line',["B","C"], {strokeColor:'#00ff00',strokeWidth:2, straightFirst:false})
				@graph.on 'move', () =>
					if @points[0].X()>@points[1].X()-.1 then @points[0].moveTo([@points[1].X()-.1, @points[0].Y()])
					if @points[2].X()<@points[1].X()+.1 then @points[2].moveTo([@points[1].X()+.1, @points[2].Y()])
					@points[1].moveTo([@points[1].X(), 0]) # Force le point B en y=0
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
					@config.graphContainer.graph.create('line',mM.float([[@data.A.x,@data.A.y],[@data.B.x,@data.B.y]]), {strokeColor:'blue',strokeWidth:1,fixed:true,dash:2})
			}
		]
