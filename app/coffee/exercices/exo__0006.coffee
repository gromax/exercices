
Exercice.liste.push
	id:6
	title:"Placer des points dans un repère"
	description:"Connaissant leurs coordonnées, placer des points dans un repère. L'exercice existe aussi dans une variante où les coordonnées sont données sous forme complexe."
	keyWords:["Géométrie", "Repère", "Complexes", "Seconde", "1STL"]
	template:"2cols"
	options: {
		a:{ tag:"complexes", options:["non", "oui"], def:0}
	}
	max:11
	init: (data) ->
		iPts = ( mM.alea.vector({ name:name, def:data.inputs, values:[{min:-@max+1, max:@max-1}]}).save(data.inputs) for name in ["A", "B", "C", "D", "E"] )
		uPts = ( mM.alea.vector({ name:name, def:data.answers, values:[{min:-@max+1, max:@max-1}]}) for name in ["A", "B", "C", "D", "E"] )
		graphContainer = new BGraph {
			params: {axis:true, grid:true, boundingbox:[-@max,@max,@max,-@max]}
			zone:"gauche"
			pts:uPts
			customInit: ()->
				@points = ( @graph.create('point',mM.float [pt.x,pt.y], {name:pt.name, fixed:false, size:4, snapToGrid:true, color:'blue', showInfoBox:false}) for pt in uPts )
		}
		if data.options.a.value is 0
			liste = ( "$#{pt.texLine()}$" for pt in iPts )
			enonce = "Vous devez placer les point suivants : <ul><li>#{ liste.join('</li><li>') }</li></ul>"
			data.tex = {
				liste:liste
				enonce: "Vous devez placer les points "
			}
		else
			liste = ( "$z_#{pt.name} = #{pt.affixe().tex()}$" for pt in iPts )
			enonce = "Dans le plan complexe, vous devez placer les point $A$, $B$, $C$, $D$, $E$ dont les affixes respectives sont : <ul><li>#{ liste.join('</li><li>') }</li></ul>"
			data.tex = {
				liste:liste
				enonce: "Dans le plan complexe, placez les points $A$, $B$, $C$, $D$, $E$ d'affixes"
			}
		[
			new BEnonce {
				zone:"droite"
				zones:[
					{body:"enonce", html:enonce }
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
						output = { user: p.name+"(#{numToStr x, 2};#{numToStr y, 2})" }
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
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itemData,i in data
			out.push {
				title:@title
				contents: [
					Handlebars.templates["tex_courbes"] { max:@max, scale:.03*@max }
					itemData.tex.enonce + " " + itemData.tex.liste.join(" ; ")
				]
			}
		out
