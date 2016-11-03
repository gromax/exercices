
Exercice.liste.push
	id:39
	title:"Associer tableaux de variations et fonctions du second degré"
	description:"Cinq paraboles et cinq fonctions du second degré sont données. À chaque fonction, il faut attribuer le tableau qui lui correspond."
	keyWords:["Analyse","Fonction","Tableau de variation", "Forme canonique", "Second degré","Seconde"]
	template:"2cols"
	init: (data) ->
		max = 6
		items = []
		inp = data.inputs
		# Les paraboles sont définies par sommet et point
		liste = [{cano:true, convexe:true}, {cano:true, convexe:false}, {cano:false, convexe:true}, {cano:false, convexe:false}]
		arrayShuffle(liste)
		tabs = []
		for cas, i in liste
			if (typeof inp["xA"+i] isnt "undefined") and (typeof inp["yA"+i] isnt "undefined") and (typeof inp["xB"+i] isnt "undefined") and (typeof inp["yB"+i] isnt "undefined") and (typeof inp["c"+i] isnt "undefined")
				xA = Number inp["xA"+i]
				yA = Number inp["yA"+i]
				xB = Number inp["xB"+i]
				yB = Number inp["yB"+i]
				cano = Boolean inp["c"+i]
			else
				# On tire au hasard 4 pts et on calcule la fonction correspondante
				# En tenant compte du cas présent
				xA = inp["xA"+i] = xB = mM.alea.real { min:-max, max:max }
				xB = inp["xB"+i] = mM.alea.real({ min:-max, max:max }) while (xA is xB)
				if cas.convexe
					yA = inp["yA"+i] = mM.alea.real { min:1, max:max-1 }
					yB = inp["yB"+i] = mM.alea.real { min:-max, max:yA-1 }
				else
					yA = inp["yA"+i] = mM.alea.real { min:-max+1, max:-1 }
					yB = inp["yB"+i] = mM.alea.real { min:yA+1, max:max }
				cano = inp["c"+i] = cas.cano
			poly = mM.exec [ yB, yA, "-", xB, xA, "-", 2, "^", "/", "x", xA, "-", 2, "^", "*", yA, "+" ], { simplify:true, developp:not cano }
			item = { rank:i, title: "$x \\mapsto "+poly.tex({canonique:cano})+"$" }
			tabX = ["$-\\infty$", "$#{xA}$", "$+\\infty$"]
			if yB>yA then variations = "+/$+\\infty$,-/$#{yA}$,+/$+\\infty$"
			else variations = "-/$-\\infty$,+/$#{yA}$,-/$-\\infty$"
			tab = (new TabVar(tabX, {hauteur_ligne:25, color:colors(i).html, texColor:colors(i).tex})).addVarLine(variations)
			tabs.push tab
			items.push item
		data.items = items
		data.tabs = tabs
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>On vous donne 4 tableaux de variations et 4 fonctions du second degré. Vous devez dire à quelle fonction correspond chaque tableau.</p>"
				}
				{
					help:data.divId+"aide"
					html:Handlebars.templates.help oHelp.trinome.canonique_et_parabole.concat(oHelp.trinome.a_et_concavite_parabole)
				}
			]}
			new BaseBrique {
				zone:"gauche"
				tabs:tabs
				fcts: {
					makeContainer: ->
						"<div id='#{@divId}'>"+("<div id='#{@divId}_tab#{i}'></div>" for tab,i in @config.tabs).join("")+"</div>"
					display: ->
						tab.render $("##{@divId}_tab#{i}") for tab,i in @config.tabs
				}
			}
			new BChoice {
				data:data
				bareme:100
				liste:items
				zone:"droite"
				title:"Cliquez sur les rectangles pour choisir la couleur du tableau correspondant à chaque fonction, puis validez"
				aide:data.divId+"aide"
			}
		]
	tex: (data,slide) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itemData in data
			if slide is true
				out.push {
					title:"Associer tableaux et fonctions"
					contents: [
						Handlebars.templates["tex_plain"] { multicols:2, contents:(tab.tex() for tab in itemData.tabs) }
						Handlebars.templates["tex_enumerate"] { multicols:2, items:(item.title for item in itemData.items)}
					]
				}
			else
				out.push {
					title:"Associer tableaux et fonctions"
					contents: (tab.tex( { color:false } ) for tab in itemData.tabs).concat(Handlebars.templates["tex_enumerate"] { items:(item.title for item in itemData.items)})
				}
		out
