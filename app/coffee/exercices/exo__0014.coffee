
Exercice.liste.push
	id:14
	title:"Associer droites et fonctions affines"
	description:"On donne cinq fonctions affines et cinq droites. Il faut associer chaque fonction affine avec la droite qui la représente."
	keyWords:["Analyse","Fonction","Courbe","Affine","Seconde"]
	template:"2cols"
	init: (data) ->
		inp = data.inputs
		max=6
		items = []
		pts = []
		for i in [0..4]
			A = mM.alea.vector({ name:"A#{i}", def:data.inputs, values:[{min:-max, max:max}] }).save(data.inputs)
			B = mM.alea.vector({ name:"B#{i}", def:data.inputs, values:[{min:-max, max:max}], forbidden:[ {axe:"x", coords:A} ] }).save(data.inputs)
			item= { color:colors(i).html, rank:i, title:"$"+ mM.droite.par2pts(A,B).affineTex("","x",true)+"$" }
			pts.push [A,B,item.color]
			items.push item
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>On vous donne 5 courbes et 5 fonctions affines. Vous devez dire à quelle fonction correspond chaque courbe.</p>"
				}
				{
					help:data.divId+"aide"
					html:Handlebars.templates.help oHelp.fonction.affine.courbe
				}
			]}
			new BGraph {
				params:{axis:true, grid:true, boundingbox:[-max,max,max,-max]}
				zone:"gauche"
				pts:pts
				customInit:->
					@graph.create('line',[AB[0].toJSXcoords(),AB[1].toJSXcoords()], {strokeColor:AB[2],strokeWidth:4, fixed:true}) for AB in @config.pts
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
