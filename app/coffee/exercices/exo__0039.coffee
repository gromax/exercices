
Exercice.liste.push
	id:39
	title:"Associer tableaux de variations et fonctions du second degré"
	description:"Cinq paraboles et cinq fonctions du second degré sont données. À chaque fonction, il faut attribuer le tableau qui lui correspond."
	keyWords:["Analyse","Fonction","Tableau de variation", "Forme canonique", "Second degré","Seconde"]
	template:"2cols"
	init: (data) ->
		max = 6
		items=[]
		inp = data.inputs
		# Les paraboles sont définies par sommet et point
		liste = [{cano:true, convexe:true}, {cano:true, convexe:false}, {cano:false, convexe:true}, {cano:false, convexe:false}]
		Tools.arrayShuffle(liste)
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
				xA = inp["xA"+i] = xB = Tools.aleaEntreBornes(-max,max)
				xB = inp["xB"+i] = Tools.aleaEntreBornes(-max,max) while (xA is xB)
				if cas.convexe
					yA = inp["yA"+i] = Proba.aleaEntreBornes(1,max-1)
					yB = inp["yB"+i] = Proba.aleaEntreBornes(-max,yA-1)
				else
					yA = inp["yA"+i] = Proba.aleaEntreBornes(-max+1,-1)
					yB = inp["yB"+i] = Proba.aleaEntreBornes(yA+1,max)
				cano = inp["c"+i] = cas.cano
			poly = Polynome.make([-xA, 1]).puissance(2)
			fact = NumberManager.makeNumber({numerator:yB-yA, denominator:poly.toNumber(xB)}).simplify()
			poly = poly.mult(fact).addMonome(0,yA)
			item = { rank:i, title: "$x \\mapsto "+poly.tex({canonique:cano})+"$" }
			tabX = ["$-\\infty$", "$#{xA}$", "$+\\infty$"]
			if yB>yA then variations = "+/$+\\infty$,-/$#{yA}$,+/$+\\infty$"
			else variations = "-/$-\\infty$,+/$#{yA}$,-/$-\\infty$"
			tab = (new TabVar(tabX, {hauteur_ligne:25, color:h_colors[i]})).addVarLine(variations)
			tabs.push tab
			items.push item
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>On vous donne 5 tableaux de variations et 4 fonctions du second degré. Vous devez dire à quelle fonction correspond chaque tableau.</p>"
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

