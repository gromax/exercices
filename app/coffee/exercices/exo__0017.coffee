
Exercice.liste.push
	id:17
	title:"Associer courbes et fonctions du second degré"
	description:"Cinq paraboles sont données. On propose cinq fonctions du second degré dont on ne connait que le discriminant et le coefficient du terme de second degré. À chaque fonction, il faut attribuer la parabole qui la représente."
	keyWords:["Analyse","Fonction","Courbe","Affine","Seconde"]
	template:"2cols"
	max:6
	init: (data) ->
		max=@max
		items = []
		polys = []
		# Les paraboles sont définies par sommet et point
		liste = [{ap:false, d:-1}, {ap:false, d:0}, {ap:false, d:1}, {ap:true, d:-1}, {ap:true, d:0}, {ap:true, d:1}]
		Tools.arrayShuffle(liste)
		inp = data.inputs
		for i in [0..4]
			if (typeof inp["xA"+i] isnt "undefined")
				xA = Number inp["xA"+i]
				yA = Number inp["yA"+i]
				xB = Number inp["xB"+i]
				yB = Number inp["yB"+i]
			else
				cas = liste.shift()
				# On tire au hasard 4 pts et on calcule la fonction correspondante
				xA = inp["xA"+i] = xB = Proba.aleaEntreBornes(-max+1,max-1)
				xB = Proba.aleaEntreBornes(-max+1,max-1) while (xA is xB)
				inp["xB"+i] = xB
				switch
					when cas.ap and (cas.d is -1)
						yA = Proba.aleaEntreBornes(1,max-1)
						yB = Proba.aleaEntreBornes(yA+1,max)
					when not cas.ap and (cas.d is 1)
						yA = Proba.aleaEntreBornes(1,max-1)
						yB = Proba.aleaEntreBornes(-max,yA-1)
					when not cas.ap and (cas.d is -1)
						yA = Proba.aleaEntreBornes(-max+1,-1)
						yB = Proba.aleaEntreBornes(-max,yA-1)
					when cas.ap and (cas.d is 1)
						yA = Proba.aleaEntreBornes(-max+1,-1)
						yB = Proba.aleaEntreBornes(yA+1,max)
					when cas.ap
						yA = 0
						yB = Proba.aleaEntreBornes(1,max)
					else
						yA = 0
						yB = Proba.aleaEntreBornes(-max,-1)
				inp["yA"+i] = yA
				inp["yB"+i] = yB
			poly = Polynome.make([-xA, 1]).puissance(2)
			fact = NumberManager.makeNumber({numerator:yB-yA, denominator:poly.toNumber(xB)}).simplify()
			poly = poly.mult(fact).addMonome(0,yA)
			color = colors(i)
			item = { color:color.html, rank:i, title:"$\\Delta = #{poly.discriminant().tex()}$ et $a = #{poly.getCoeff(2).tex()}$"}
			items.push item
			polys.push { obj:poly, color:color }
			data.polys = polys
			data.items = items
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>On vous donne 5 cas de fonctions du second degré, donc de la forme $f:x\\mapsto ax^2+bx+c$ dont on ne connaît que la valeur de $\\Delta$ et la valeur de $a$. Vous devez les associer aux courbes.</p>"
				}
				{
					help:data.divId+"aide"
					html:Handlebars.templates.help oHelp.trinome.a_et_concavite_parabole.concat(oHelp.trinome.delta_et_parabole)
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
							(x) -> @getAttribute('poly').toNumber(x)
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
	tex: (data,slide) ->
		if not Tools.typeIsArray(data) then data = [ data ]
		out = []
		for itemData,i in data
			courbes = ( { color:item.color.tex, expr:item.obj.toClone().simplify().toString().replace(/,/g,'.').replace(/x/g,'(\\x)') } for item in itemData.polys )
			Tools.arrayShuffle itemData.items
			questions = Handlebars.templates["tex_enumerate"] { items:( item.title for item in itemData.items ) }
			graphique = Handlebars.templates["tex_courbes"] { index:i+1, max:@max, courbes:courbes, scale:.5 }
			if slide is true
				out.push {
					title:@title
					content:Handlebars.templates["slide_cols"] {
						cols:[
							{ width:0.6, center:true, content:graphique}
							{ width:0.4, content:questions }
						]
					}
				}
			else
				out.push {
					title:@title
					contents:[graphique, questions]
				}
		out
