
Exercice.liste.push
	id:48
	max:6
	title: "Reconnaître les courbes d'une fonction et de sa dérivée (ou d'une fonction et et de sa primitive)"
	description: "On donne la courbe d'une fonction $f$ et la courbe de sa dérivée $f'$ (ou de sa primitive $F$), il faut reconnaître quelle courbe correspond à $f$ et quelle courbe correspond à $f'$ (ou $F$)."
	keyWords:["Analyse", "Déerivation", "Première", "Primitive", "Terminale"]
	template:"2cols"
	options: {
		a:{ tag:"Dérivée ou Primitive" , options:["Dérivée", "Primitive"] , def:0 }
	}
	init: (data) ->
		if data.options.a.value is 0
			tag_poly = "f"
			tag_polyDer = "f'"
			html_enonce = "<p>On vous donne 2 courbes. L'une d'elle correspond à la fonction $f$ et l'autre à sa dérivée $f'$. Vous devez associer chaque courbe avec $f$ ou $f'$.</p>"
			data.title = "Reconnaître les courbes d'une fonction et de sa dérivée"
			template_aide = oHelp.derivee.variation
		else
			tag_poly = "F"
			tag_polyDer = "f"
			html_enonce = "<p>On vous donne 2 courbes. L'une d'elle correspond à la fonction $f$ et l'autre à une de ses primitive $F$. Vous devez associer chaque courbe avec $f$ ou $F$.</p>"
			data.title = "Reconnaître les courbes d'une fonction et de sa primitive"
			template_aide = oHelp.primitive.variation
		# Initialisation du polynome
		inp = data.inputs
		poly = null
		if typeof inp.p isnt "undefined"
			poly = NumberManager.makeNumber(inp.p).toPolynome("x")
			if not poly.isValid() then poly = null
		if poly is null
			# On crée un nouveau polynome
			points = [
				{x:-@max, y:Proba.aleaEntreBornes(-40,40)/100*@max},
				{x:-@max/2, y:Proba.aleaEntreBornes(-40,40)/100*@max},
				{x:0, y:Proba.aleaEntreBornes(-40,40)/100*@max},
				{x:@max/2, y:Proba.aleaEntreBornes(-40,40)/100*@max},
				{x:@max, y:Proba.aleaEntreBornes(-40,40)/100*@max}
			]
			poly = Polynome.lagrangian(points, "x")
			inp.p = String(poly)
		# Calcul de la dérivée
		polyDer = poly.derivate()
		col = Math.floor(Math.random() * 2)
		polys = data.polys = [
			{ obj:poly, color:colors(col) }
			{ obj:polyDer, color:colors(1-col)}
		]
		items = [
			{ rank:col, title: "$#{tag_poly}$" }
			{ rank:1-col, title: "$#{tag_polyDer}$" }
		]

		# Pour le debug
		#if data.isAdmin
		#	console.log "fct : #{poly.toClone().simplify().toString().replace(/,/g,'.').replace(/x/g,'(\\x)')}"
		#	console.log "der : #{polyDer.toClone().simplify().toString().replace(/,/g,'.').replace(/x/g,'(\\x)')}"
		# Objet de sortie :
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:html_enonce
				}
				{
					help:data.divId+"aide"
					html:Handlebars.templates.help template_aide
				}
			]}
			new BGraph {
				params:{axis:true, grid:true, boundingbox:[-@max,@max,@max,-@max]}
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
				title:"Cliquez sur les rectangles pour choisir la couleur de la courbe correspondant à chaque item, puis validez"
				aide:data.divId+"aide"
			}
		]
	tex: (data,slide) ->
		if not Tools.typeIsArray(data) then data = [ data ]
		out = []
		for itemData,i in data
			if itemData.options.a.value is 0
				title = "Identifier la courbe de $f$ et celle de sa dérivée $f'$"
			else
				title = "Identifier la courbe de $f$ et celle de sa primitive $F$"
			courbes = ( { color:item.color.tex, expr:item.obj.toClone().simplify().toString().replace(/,/g,'.').replace(/x/g,'(\\x)') } for item in itemData.polys )
			graphique = Handlebars.templates["tex_courbes"] { index:i+1, max:@max, courbes:courbes, scale:.6*@max/6, center:true }
			out.push {
				title:title
				content:graphique
			}
		out
