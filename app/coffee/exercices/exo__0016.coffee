
Exercice.liste.push
	id:16
	title:"Associer courbes et fonctions du second degré"
	description:"Cinq paraboles et cinq fonctions du second degré sont données. À chaque fonction, il faut attribuer la parabole qui la représente."
	keyWords:["Analyse","Fonction","Courbe","Second degré","Seconde"]
	template:"2cols"
	init: (data) ->
		max=6
		items = []
		polys = []
		# Les paraboles sont définies par sommet et point
		for i in [0..4]
			A = Vector.makeRandom "A"+i, data.inputs, { ext:[[-max,max]] }
			B = Vector.makeRandom "B"+i, data.inputs, { ext:[[-max,max]] }
			f = h_init("f"+i,data.inputs,1,3)
			while A.sameAs(B,"x") or A.sameAs(B,"y")
				B = Vector.makeRandom "B"+i, data.inputs, { overwrite:true, ext:[[-max,max]] }
			poly = Polynome.make([A.x.toClone().opposite(), 1]).puissance(2)
			fact = B.y.toClone().am(A.y,true).md(poly.calc(B.x),true)
			poly = poly.mult(fact).addMonome(0,A.y).simplify()
			item = { color:h_colors[i], rank:i, title: "$x \\mapsto #{poly.tex({canonique:f is 1})}$" }
			polys.push [poly,item.color]
			items.push item
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
				customInit:->
					for poly in @config.polys
						@graph.create('functiongraph', [
							(x) -> @getAttribute('poly').toNumber(x)
							-max, max], {strokeColor:poly[1], strokeWidth:4, fixed:true, poly:poly[0] })
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
