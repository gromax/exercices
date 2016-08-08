
Exercice.liste.push
	id:15
	title:"Associer droites et équations réduites"
	description:"On donne cinq équations réduites et cinq droites. Il faut associer chaque équation avec la droite qui la représente."
	keyWords:["Analyse","Fonction","Courbe","Affine","Seconde"]
	template:"2cols"
	options: {
		n:{ tag:"Nombre de courbes" , options:["3", "4", "5", "6", "7"] , def:2 }
	}
	init: (data) ->
		N = data.options.n.value+2
		max=6
		items = []
		pts = []
		for i in [0..N]
			A = Vector.makeRandom "A"+i, data.inputs, { ext:[[-max,max]] }
			B = Vector.makeRandom "B"+i, data.inputs, { ext:[[-max,max]] }
			while A.sameAs B
				B = Vector.makeRandom "B"+i, data.inputs, { overwrite:true, ext:[[-max,max]] }
			item= { color:h_colors[i], rank:i, title:"$"+ Droite2D.par2Pts(A,B).reduiteTex()+"$" }
			pts.push [A,B,item.color]
			items.push item
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>On vous donne des droites et des équations de droites. Vous devez dire à quelle équation correspond chaque droite.</p>"
				}
				{
					help:data.divId+"aide"
					html:Handlebars.templates.help oHelp.droite.associer_equation
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
				title:"Cliquez sur les rectangles pour choisir la couleur de la courbe correspondant à chaque équation, puis validez"
				aide:data.divId+"aide"
			}
		]

