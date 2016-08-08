
Exercice.liste.push
	id:6
	title:"Placer des points dans un repère"
	description:"Connaissant leurs coordonnées, placer des points dans un repère."
	keyWords:["Géométrie", "Droite", "Équation", "Seconde"]
	template:"2cols"
	init: (data) ->
		iPts = Vector.makeRandoms ["A", "B", "C", "D", "E"], data.inputs
		uPts = Vector.makeRandoms ["A", "B", "C", "D", "E"], data.answers, { save:false }
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-11,11,11,-11]}
			zone:"gauche"
			pts:uPts
			customInit: ()->
				@points = ( @graph.create('point',[pt.x.toNumber(),pt.y.toNumber()], {name:pt.name, fixed:false, size:4, snapToGrid:true, color:'blue', showInfoBox:false}) for pt in uPts )
		}

		[
			new BEnonce {
				zone:"droite"
				zones:[
					{body:"enonce", html:"<p>Vous devez placer les point suivants : $#{ ( pt.texLine() for pt in iPts ).join(", ") }$</p>"}
				]
			}
			graphContainer
			new BPoints {
				data:data
				bareme:100
				graphContainer:graphContainer
				zone:"droite"
				verif_point:(p)->
					x=p.X()
					y=p.Y()
					g_x = Number @data.inputs["x"+p.name]
					g_y = Number @data.inputs["y"+p.name]
					d2 = (x-g_x)*(x-g_x)+(y-g_y)*(y-g_y)
					if d2<0.1
						# Le point est assez près
						output = { user: p.name+"(#{x.toStr 2};#{y.toStr 2})" }
						unless d2 is 0 then output.approx = true
					else
						output = { good: p.name }
						if (y-g_x)*(y-g_x)+(x-g_y)*(x-g_y)<0.1 then output.xy_inverse = true
					output
				el:(p) ->
					name=p.name
					g_x = Number @data.inputs["x"+name]
					g_y = Number @data.inputs["y"+name]
					@config.graphContainer.graph.create 'point',[g_x,g_y], {name:name, fixed:true, size:4, color:'green'}
			}
		]
