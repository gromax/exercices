
Exercice.liste.push
	id:16
	title:"Associer courbes et fonctions du second degré"
	description:"Cinq paraboles et cinq fonctions du second degré sont données. À chaque fonction, il faut attribuer la parabole qui la représente."
	keyWords:["Analyse","Fonction","Courbe","Second degré","Seconde"]
	template:"2cols"
	max:6
	init: (data) ->
		max=@max
		items = []
		polys = []
		# Les paraboles sont définies par sommet et point
		for i in [0..4]
			A = mM.alea.vector({ name:"A#{i}", def:data.inputs, values:[{min:-max, max:max}] }).save(data.inputs)
			B = mM.alea.vector({ name:"B#{i}", def:data.inputs, values:[{min:-max, max:max}], forbidden:[ {axe:"x", coords:A}, {axe:"y", coords:A} ] }).save(data.inputs)
			if data.inputs["f"+i]? then f = Number data.inputs["f"+i]
			else
				if cano = mM.alea.dice(1,3) then f = 1 else f = 0
				data.inputs["f"+i] = String f
			poly = mM.exec [ B.y, A.y, "-", B.x, A.x, "-", 2, "^", "/", "x", A.x, "-", 2, "^", "*", A.y, "+" ], { simplify:true, developp:f isnt 1 }
			color = colors(i)
			item = { color:color.html, rank:i, title: "$x \\mapsto #{poly.tex()}$" }
			polys.push { obj:poly, color:color }
			data.polys  = polys
			items.push item
			data.items = items
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>On vous donne 5 courbes et 5 fonctions du second degré. Vous devez dire à quelle fonction correspond chaque courbe.</p>"
				}
				{
					help:data.divId+"aide"
					html:Handlebars.templates.help oHelp.trinome.a_et_concavite_parabole.concat(oHelp.trinome.canonique_et_parabole,oHelp.trinome.c_et_parabole)

				}
			]}
			new BGraph {
				params:{axis:true, grid:true, boundingbox:[-max,max,max,-max]}
				zone:"gauche"
				polys:polys
				max:@max
				customInit:->
					for poly in @config.polys
						@graph.create('functiongraph', [
							(x) -> mM.float(@getAttribute('poly'), {x:x})
							-@config.max, @config.max], {strokeColor:poly.color.html, strokeWidth:4, fixed:true, poly:poly.obj })
			}
			new BChoice {
				data:data
				bareme:100
				liste:items
				zone:"droite"
				title:"Cliquez sur les rectangles pour choisir la couleur de la courbe correspondant à chaque fonction, puis validez"
				aide:data.divId+"aide"
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itemData,i in data
			courbes = ( { color:item.color.tex, expr:item.obj.toClone().simplify().toString().replace(/,/g,'.').replace(/x/g,'(\\x)') } for item in itemData.polys )
			arrayShuffle itemData.items
			questions = Handlebars.templates["tex_enumerate"] { items:( item.title for item in itemData.items ) }
			graphique = Handlebars.templates["tex_courbes"] { index:i+1, max:@max, courbes:courbes, scale:.6*@max/6 }
			out.push {
				title:@title
				contents:[graphique, questions]
			}
		out
