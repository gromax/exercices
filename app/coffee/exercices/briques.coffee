# Brique de base
class BaseBrique
	default: () -> {}
	mergeConf: (def,overrideObj) ->
		if (typeof overrideObj isnt "object") or (overrideObj is null) then return def
		def[key] = val for key, val of overrideObj
		if arguments.length>2
			i=2
			while i<arguments.length
				o = arguments[i]
				if (typeof o is "object") and (o isnt null)
					def[key] = val for key, val of o
				i++
		def
	constructor: (params)->
		@config = @mergeConf @default(), params
		# Fonctions custom
		if @config.fcts?
			@[fct]=@config.fcts[fct] for fct of @config.fcts
	inputSetError:(name,valid) ->
		if valid then $("input[name='#{name}']").parent().removeClass("has-error")
		else $("input[name='#{name}']").parent().addClass("has-error")

# Brique pour l'affichage de l'énoncé
class BEnonce extends BaseBrique
	default: () -> { title:"Énoncé", template:"std_panel"}
	makeContainer: ->
		Handlebars.templates[@config.template] @config

#Brique pour l'affichage des graphiques
class BGraph extends BaseBrique
	makeContainer: ->
		"<div>#{Handlebars.templates.std_graph({ id:@divId})}</div>"
	display: ->
		$("##{@divId}").adjustSize()
		@graph = JXG.JSXGraph.initBoard(@divId,@config.params,keepaspectratio:true)
		@config.customInit?.apply(@,[])
	addPoint: (name, coords, def_coords, params) ->
		conf = @mergeConf { color:"blue", size:4, name:name, fixed:false, stapToGrid:false, showInfoBox:true }, params
		x = coords.x or def_coords?.x
		y = coords.y or def_coords?.y
		return @graph.create('point',[x,y], conf)

# le default des classes est une fonction car autrement l'objet default est commun à toutes les instances d'une même classe !

class Brique extends BaseBrique
	default: () -> {}
	constructor: (params)->
		super params
		@bareme = @config.bareme ? 0
		@data = @config.data ? { answers:{}, inputs:{}, note:0 }
		# Les réponses : @data.answers contient les string des réponses utilisateur
		@a = @data.answers
		# Fonctions custom
		if @config.ask then @ask = @config.ask
		if @config.ver then @ver = @config.ver
	initContainer:-> unless @container? then @container = $("#"+( @divId ? "inex" ))
	makeContainer: ->
		"<div id='#{@divId}'>"+Handlebars.templates[@config.waitingTemplate ? "waitingPanel"]({title:(@config.pretitle ? @config.title) ? "En attente"})+"</div>"
	followInputSelection: ($node) ->
		@inputSelection = {start: $node.getSelectionStart(), end: $.getSelectionEnd(), last: $node}
	clavier: ($node, pre_car,post_car,efface) ->
		# Détecte la position de début et de fin de la sélection
		# écrit pre_car avant, post_car après, et efface indique si on laisse la sélection
		if typeof @inputSelection is "undefined" then @inputSelection = { start:0, end:0, last:$node }
		inp = @inputSelection.last
		text = inp.val()
		if efface
			selection = ""
			delta = @inputSelection.start - @inputSelection.end + pre_car.length + post_car.length
		else
			selection = text.substring(@inputSelection.start, @inputSelection.end)
			delta = pre_car.length + post_car.length
		newText = text.substring(0,@inputSelection.start)+pre_car+selection+post_car+text.substring(@inputSelection.end)
		inp.val(newText)
		inp.setCursorPosition(@inputSelection.end+delta)
	go: () ->
		# fonction par défaut
		if @config.needed?
			for name in @config.needed
				if (typeof @a[name] is "undefined") then return false
		true
	ask: ->
		if (template = @config.customAskTemplate?()) then @container.html Handlebars.templates[template.templateName]?(template)
		$("form",@container).on 'submit', (event) =>
			if not( @config.customFormValidation?(event) ) and (@config.needed?)
				@a[inp] = $("input[name='#{inp}']",@container).val() for inp in @config.needed
			@run true
			false
		if @config.foccus? then $("input[name='#{@config.focus}']",@container).focus()
	ver: ->
		@container.html Handlebars.templates.std_panel {
			title:@title
			zones:@config.customVerif?()
		}
	run: (upBDD) -> @parent?.run(upBDD)


#-------------------------------------------------------
# Objet item pour la brique BListe
#-------------------------------------------------------
class BItem
	# BItem est un item pour BListe qui s'assure de l'intégrité des informations fournies
	# et qui donne aussi les fonctions de correction (verif), de validation (go)
	# Les paramètres sont les suivants :
	# - tag : le tag à afficher à gauche du input correspondant
	# - postTag : tag après le champ
	# - name : le nom pour le node html correspondant et aussi le nom pour l'objet answers stocké en bdd
	# - description : ce qui apparaît dans le champ vide
	# - large : true/false indique s'il faut un champ allongé
	# - text : Un message à placer avant le input
	# - moduloKey : une lettre de variable pour le modulo, comme k dans 2kpi
	# - un choix entre plusieurs options pour la bonne solution :
	# -- good : Solution unique qui peut être number, ensemble, équation
	# -- equations : objets équations, séparées de ; ou ∅ pour rien
	# -- solutions : objets numbers multiples, séparées de ; ou ∅ pour rien
	# - customTemplate : Une fonction qui renvoie un tableau de string à ajouter dans un template
	# - Des paramètres concernant le parse :
	# -- simplify : true/false
	# -- alias : { key:[v1, v2] }, chaque occurence de v1, v2... est remplacée par key
	# -- developp : true/false
	# -- toLowerCase : true/false

	# - params : paramètres de parse et de notation. Il contient :
	# -- Des éléments de correction comme arrondi, approximation, custom()
	# -- Des éléments de parse comme type, developp
	name:"a"
	moduloKey: false
	customTemplate: () -> []
	constructor: (item) ->
		if item.name? then @name = item.name
		@parseParams = {
			type:item.type ? ""
			developp:item.developp is true
			toLowerCase:item.toLowerCase is true
			alias : item.alias ? false
		}
		@verifParams = {
			arrondi : item.arrondi ? false
			formes : item.formes ? null
			custom: if typeof item.customVerif is "function" then item.customVerif else null
			tolerance : item.tolerance ? false
		}
		@templateParams = {
			name:item.name					# nécessaire pour les inputs
			arrondi:item.arrondi ? false	# Si on demande un arrondi, on précise ici une puissance (-2 pour 0.01 par ex.)
			cor_prefix:item.cor_prefix ? ""	# Permet d'ajouter un préfixe à la valeur correction. Différent de goodTex car permet de préfixer également le userTex
			tag: item.tag ? false			# Étiquette, devant le input
			postTag:item.postTag ? false	# Étiquette, après le input
			large:item.large is true		# input de grande taille
			description:item.description ? ""	# Dans le input, s'il est vide (placeholder)
			text:item.text ? false			# texte à placer avant le input
			user:""							# réponse utilisateur
			invalid:false					# champ invalide
			custom: if typeof item.customTemplate is "function" then item.customTemplate else () -> false
		}

		if typeof item.moduloKey is "string" then @moduloKey = item.moduloKey
		switch
			when item.solutions?
				@templateParams.corTemplateName = "cor_solutions"
				unless @text? then @templateParams.text = "Donnez les solutions séparées par ; ou $\\varnothing$ s'il n'y en a pas"
				@solutions = ( mM.toNumber(it) for it in item.solutions )
				@parseParams.type = "number"
				@go = @go_solutions
				@verif = @verif_solutions
			when item.equations?
				@templateParams.corTemplateName = "cor_solutions"
				unless @text? then @templateParams.text = "Donnez les solutions séparées par ; ou $\\varnothing$ s'il n'y en a pas"
				@solutions = item.equations
				@parseParams.type = "equation"
				@go = @go_solutions
				@verif = @verif_solutions
			else # par défaut, ce sera un item avec good
				goodArray = null
				goodValue = null
				switch
					when isArray(item.good)
						switch item.good.length
							when 0 then goodValue = 0
							when 1 then goodValue = item.good[0]
							else
								goodArray = item.good
								goodValue  = item.good[0]
					when typeof item.good is "undefined" then goodValue = 0
					else goodValue = item.good
				@parseParams = mM.p.type goodValue, @parseParams
				if goodArray isnt null
					if (@parseParams.type is "number") then @good = ( mM.toNumber(it) for it in goodArray )
					else @good = goodArray
				else
					if (@parseParams.type is "number") then @good = mM.toNumber(goodValue)
					else @good = goodValue
				@templateParams.corTemplateName = "cor_number"
				if typeof item.goodTex is "string" then @templateParams.goodTex = item.goodTex
				else @templateParams.goodTex = @good.tex()
				@go = (answers) ->
					user = answers[@name]
					if (typeof user isnt "string")
						# Dans ce cas, le champ n'est pas invalide car il n'a rien reçu
						@templateParams.invalid = false
						false
					else
						@templateParams.user = user
						@info = mM.p.userAnswer user, @parseParams
						@templateParams.userTex = @info.tex
						@templateParams.invalid = not(@info.valid)
						@templateParams.parseMessages = @info.messages.join(" ; ")
						@info.valid
				@verif = () ->
					if isArray(@good)
						verif_result = ( mM.verif[@parseParams.type](@info, it,@verifParams) for it in @good)
						verif_result.sort (a,b) ->
							if b.ponderation>a.ponderation then -1
							else 1
						verif_result = verif_result.pop()
					else verif_result = mM.verif[@parseParams.type](@info, @good,@verifParams)
					@templateParams.customItems = @templateParams.custom(verif_result)
					@templateParams[key] = value for key,value of verif_result
					verif_result.ponderation
	go_solutions: (answers) ->
		user = answers[@name]
		switch
			when (typeof user isnt "string")
				# Dans ce cas, le champ n'est pas invalide car il n'a rien reçu
				@templateParams.invalid = false
				false
			when user is "∅"
				@templateParams.user = "∅"
				@info = []
				@templateParams.invalid = false
				true
			else
				@templateParams.user = user
				if @moduloKey then user = user.replace(new RegExp(@moduloKey,"g"), "#")
				users = ( mM.p.userAnswer(str, @parseParams) for str in user.split ";" when str.trim() isnt "")
				@info = (usItem for usItem in users when usItem.valid is true)
				@templateParams.invalid = (users.length>@info.length) or (users.length is 0)
				if (@templateParams.invalid) then @templateParams.parseMessages = "Vérifiez : #{ (infoItem.expression for infoItem in users when infoItem.valid is false).join(' ; ') }"
				not(@templateParams.invalid)
	verif_solutions: () ->
		# fonction servant pour les équations et les solutions
		# Si l'utilisateur a répondu ensemble vide...
		if @info.length is 0
			@templateParams[key] = value for key, value of {
				users:false
				goods:null
				bads:null
				lefts: (l.tex() for l in @solutions).join(" ; ")
				goodIsEmpty:@solutions.length is 0
			}
			if @solutions.length is 0 then 1 else 0
		else
			# On considère que l'on a une série de valeurs
			N = Math.max @solutions.length, @info.length
			sorted = mM.tri @info, @solutions
			list=[]
			goods = []
			bads = []
			for sol,i in sorted.closests
				list.push sol.user.tex()
				if sol.good?
					verif = mM.verif[@parseParams.type](sol.info, sol.good, @verifParams)
					if verif.ok
						verif.userTex = sol.info.tex
						verif.goodTex = sol.good.tex()
						goods.push verif
					else
						bads.push sol.info.tex
						sorted.lefts.push sol.good
				else bads.push sol.info.tex
			@templateParams[key] = value for key, value of {
				users:list.join(" ; ")
				goods:goods
				bads:bads.join(" ; ")
				lefts:(l.tex() for l in sorted.lefts).join(" ; ")
				goodIsEmpty:@solutions.length is 0
			}
			goods.length/N

#-------------------------------------------------------
# Briques supposant une ou plusieurs réponses à parser
#-------------------------------------------------------
class BListe extends Brique
	# Brique généraliste qui permet de demander simultanément plusieurs valeurs
	# config contient les objets suivants :
	# title : Pour le titre de la brique
	# liste : un tableau d'objets pour chaque réponse attendue. Pour chacun on a :
	# - tag : le tag à afficher à gauche du input correspondant
	# - name : le nom pour le node html correspondant et aussi le nom pour l'objet answers stocké en bdd
	# - description : ce qui apparaît dans le champ vide
	# - large : true/false indique s'il faut un champ allongé
	# - params : paramètres de parse et de notation (voir avec la vérification)
	# aide : objet d'aide pour produire le html avec le template help
	# touches : un tableau des touches utiles parmi ["infini", sqrt, pi, x2 sqr, empty] ou un objet { name, title, tag }
	# text : un texte html à faire apparaître avant les questions
	default: () ->  { liste:[], title:"titre ?" }
	constructor: (params) ->
		super(params)
		@config.liste = ( new BItem(item) for item in @config.liste ) # Il faudrait passer à @liste au lieu de @config.liste
	go: ->
		valid = true
		valid = item.go(@a) and valid for item in @config.liste # l'ordre est important !
		valid
	ask: ->
		# exploite les config suivantes :
		# title = String
		# text = String => envoyé comme texte de présentation, html non echappé
		# liste = [{tag, }]
		# aide = ["it1", "it2", ...]
		# touches = ["sqrt", "pi", "sqr", "empty", objet{name, title, tag, pre, post, recouvre}]
		clavier = null
		if @config.touches?
			clavier=[]
			for touche in @config.touches
				switch
					when touche is "infini" then clavier.push {name:"infty-button", title:"Infini", tag:"$\\infty$"}
					when touche is "sqrt" then clavier.push {name:"sqrt-button", title:"Racine carrée", tag:"$\\sqrt{x}$"}
					when touche is "pi" then clavier.push {name:"pi-button", title:"Pi", tag:"$\\pi$"}
					when touche is "sqr" then clavier.push {name:"sqr-button", title:"Carré", tag:"$.^2$"}
					when touche is "x2" then clavier.push {name:"x2-button", title:"x carré", tag:"$x^2$"}
					when touche is "empty" then clavier.push {name:"empty-button", title:"Ensemble vide", tag:"$\\varnothing$"}
					when touche is "union" then clavier.push {name:"btnU", title:"Union", tag:"$\\cup$"}
					when touche is "intersection" then clavier.push {name:"btnInter", title:"Intersection", tag:"$\\cap$"}
					when touche is "reels" then clavier.push {name:"btnReels", title:"Ensemble des réels", tag:"$\\mathbb{R}$"}
					when typeof touche is "object" then clavier.push {name:touche.name, title:touche.title, tag:touche.tag}
		inputs=(item.templateParams for item in @config.liste)
		if @config.aide?
			help_zone = "#{@divId}_aide"
			help_html = Handlebars.templates.help(@config.aide)
		else help_zone = help_html = null
		context = {
			title:@config.title
			focus:true
			zones:[{
				body:"champ"
				html:Handlebars.templates.std_form {
					id:"form#{@divId}"
					inputs:inputs
					clavier:clavier
					help_target:help_zone
				}
			}]
		}
		if help_zone isnt null then context.zones.push { help:help_zone, html:help_html}
		if @config.text?
			# On transmet soit un simple texte, soit une structure plus complexe sous forme d'un tableau
			if isArray @config.text then context.zones = @config.text.concat(context.zones)
			else context.zones.unshift { body:"texte", html:@config.text }
		@container.html Handlebars.templates.std_panel context
		$("#form#{@divId}").on 'submit', (event) =>
			aList = $(event.target).serializeObject()
			@a[item.name] = aList[item.name] for item in @config.liste
			@run true
			false
		if clavier isnt null
			$inputs_List = ($("input[name='#{item.name}']",@container) for item in @config.liste)
			@gc = new GestClavier $inputs_List...
			for touche in @config.touches
				switch
					when touche is "infini" then $("button[name='infty-button']",@container).on 'click', (event) => @gc.clavier("∞","",true)
					when touche is "sqrt" then $("button[name='sqrt-button']",@container).on 'click', (event) => @gc.clavier("sqrt(",")",false)
					when touche is "pi" then $("button[name='pi-button']",@container).on 'click', (event) => @gc.clavier("π","",true)
					when touche is "sqr" then $("button[name='sqr-button']",@container).on 'click', (event) => @gc.clavier("","^2",false)
					when touche is "x2" then $("button[name='x2-button']",@container).on 'click', (event) => @gc.clavier("x^2","",true)
					when touche is "empty" then $("button[name='empty-button']",@container).on 'click', (event) => @gc.clavier("∅","",true)
					when touche is "union" then $("button[name='btnU']",@container).on 'click', (event) => @gc.clavier("∪","",true)
					when touche is "intersection" then $("button[name='btnInter']",@container).on 'click', (event) => @gc.clavier("∩","",true)
					when touche is "reels" then $("button[name='btnReels']",@container).on 'click', (event) => @gc.clavier("ℝ","",true)
					when typeof touche is "object" then $("button[name='#{touche.name}']",@container).on 'click', (event) => @gc.clavier(touche.pre,touche.post,touche.recouvre)
		if @config.liste.length>0 then $("input[name='#{@config.liste[0].name}']",@container).focus()
	ver: ->
		# La fonction verif() renvoie la ponderation
		score = 0
		score += item.verif() for item in @config.liste
		@data.note += score*@bareme/Math.max(@config.liste.length,1)
		# De plus, l'objet verif a achevé de mettre à jour @templateParams
		@container.html Handlebars.templates.std_panel {
			title: @config.title
			zones:[{
				list:"correction"
				html: (Handlebars.templates[item.templateParams.corTemplateName](item.templateParams) for item in @config.liste).join("")
			}]
		}

#-------------------------------------------------------
# Briques sans réponse à parser
#-------------------------------------------------------
class BChoixMultiple extends Brique
	# title
	# aKey
	# choix : ["choix1","choix2",...]
	# good
	# correction: ["","",...]
	# aide: { template:"", ...}
	default: () ->  { aKey:"choix"}
	go: -> (typeof @a[@config.aKey] isnt "undefined")
	ask: () ->
		lChoix = []
		if @config.choix.length>0
			lChoix.push { title:item, value:k } for item,k in @config.choix
			lChoix[0].checked = true

		zones = []

		if @config.aide?
			zones.push {
				help: @divId+"_aide"
				html: Handlebars.templates.help(@config.aide)
			}
			help_zone_id = @divId+"_aide"
		else help_zone_id = null

		zones.unshift {
			body: "champ"
			html: Handlebars.templates.std_form {
				id:"form#{@divId}"
				inputs:[{
					radio:@config.aKey
					list:lChoix
				}]
				help_target:help_zone_id
			}
		}

		if @config.text? then zones.unshift {
			body:"texte"
			html:@config.text
		}

		@container.html Handlebars.templates.std_panel {
			title: @config.title
			focus: true
			zones: zones
		}
		$("#form#{@divId}",@container).on 'submit', (event) =>
			@a[@config.aKey] = $(event.target).serializeArray()[0].value
			@run true
			false
	ver: () ->
		k = Number @a[@config.aKey]
		if (k is @config.good)
			@data.note += @bareme
			liste = [{ text:"Vous avez choisi : #{@config.choix[k]}. C'est une <b>bonne réponse</b>.", color:"ok" }]
		else
			liste = [{ text:"Vous avez choisi : #{@config.choix[k]}. C'est une <b>mauvaise réponse</b>.", color:"error" }]
			if @config.correction?
				liste.push { text:item, color:"error" } for item in @config.correction
		@container.html Handlebars.templates.std_panel {
			title: @config.title
			zones:[{
				list:"correction"
				html:Handlebars.templates.listItem liste
			}]
		}
class BWichTab extends Brique
	default: () ->  {tableaux:[], aKey:"tableau", title:"Choisir un tableau"}
	go: -> (typeof @a[@config.aKey] isnt "undefined")
	ask: ->
		@container.html Handlebars.templates.std_panel {title:"Choix du tableau", zones:[{body:"choixTableau"}]}
		$("div[name='choixTableau']",@container).html Handlebars.templates.choixDiv {items:({name:"tableau"+i, answer:i} for tab,i in @config.tableaux)}
		for tab,i in @config.tableaux
			$divT = $("div[name='tableau#{i}']",@container)
			$divT.data("brique",@)
			tab.render $divT
			$divT.on 'click', () -> $(@).data("brique")?.select($(@).attr("answer"))
	select: (answer) ->
		@a[@config.aKey] = answer
		@run true
	ver: ->
		userChoice = Number @a[@config.aKey]
		context = { name:"tableau", good:true }
		if @config.good is userChoice then @data.note+=@bareme
		else context.good=false
		@container.html Handlebars.templates.std_panel {
			title:"Choix du tableau"
			zones:[{
				list:"correction"
				html:Handlebars.templates.choixDivCor context
			}]
		}
		@config.tableaux[@config.good]?.render $("div[name='tableau']",@container)
class BChoice extends Brique
	default: () ->  { title:"Choix", aKey:"it", liste:[], titleAnswer:"Réponse" }
	go: -> (typeof @a[@config.aKey+"0"] isnt "undefined")
	ask:(container,params) ->
		@config.answersList = (-1 for i in [1..@config.liste.length]) # Tableau contenant la liste des réponses de l'utilisateur
		arrayShuffle(@config.liste)
		@container.html Handlebars.templates.std_color_menu {title:@config.title, items:@config.liste, help_target:@config.aide }
		$("form",@container).on 'submit', (event) =>
			@a[@config.aKey+rank] = ans for ans, rank in @config.answersList
			@run true
			false
		$("span[name|='bc']",@container).on 'click', (event) => @colorListMenuClick($(event.currentTarget), @config.answersList)
	colorListMenuClick: ($node, answersList) ->
		# Menu de bouton coloré. Click sur le bouton permet de faire défiler les couleurs
		# en vue d'obtenir une association
		rank = Number($node.attr("rank"))
		if (typeof answersList[rank] is "undefined") then answersList[rank] = 0
		else answersList[rank] = answersList[rank]+1
		if answersList[rank] is answersList.length then answersList[rank] = 0
		$node.css('background-color',colors(answersList[rank]).html)
	ver: ->
		N = @config.liste.length
		for item in @config.liste
			item.user = @a[@config.aKey+item.rank]
			item.userColor = colors(item.user).html
			item.goodColor = colors(item.rank).html
			if item.user is item.rank
				item.ok = true
				@data.note+=@bareme/N
		@container.html Handlebars.templates.std_color_menu_cor { items:@config.liste }
class BPoints extends Brique
	# On peut fournir les fonctions verif_point, eg (pour erreur globale) et el (pour erreur locale)
	default: () ->  {prefix:"", liste:[], waitingTemplate:"std_valid_when_finished" }
	go: ->
		p = @config.prefix
		for item in @config.graphContainer.points
			if (typeof @a[p+"x"+item.name] is "undefined") or (typeof @a[p+"y"+item.name] is "undefined") then return false
		true
	ask: ->
		$("form",@container).on 'submit', (event) =>
			p = @config.prefix
			for pt in @config.graphContainer.points
				name = pt.name
				@a[p+"x"+name] = pt.X()
				@a[p+"y"+name] = pt.Y()
			@run true
			false
	ver: ->
		ptsListe = @config.graphContainer.points
		erreur_global = false # Flag qui devient true dès qu'un point ne colle pas
		points=[]
		bar = @bareme/Math.max(1,ptsListe.length)
		for pt in ptsListe
			points.push(correc = @config.verif_point?.apply(@,[pt]))
			pt.setProperty({fixed:true})
			if correc.good
				# On fournit le bon point, c'est qu'il est mal placé
				pt.setProperty({color:'red'})
				@config.el?.apply(@,[pt])
				erreur_global = true
			else
				pt.setProperty({color:'green'})
				@data.note+=bar
		template = Handlebars.templates.cor_points { points: points}
		if erreur_global and (typeof @config.eg isnt "undefined")
			@config.eg?.apply(@,null)
			template = Handlebars.templates.listItem([{text:"La bonne courbe est tracée en bleu.", color:"error"}]) + template
		@container.html Handlebars.templates.std_panel {
			title:"Résultats"
			zones:[{
				list:"correction"
				html:template
			}]
		}
class BGenenral extends Brique
	# Une classe générale qui se contente de gérer le formulaire
	# requiert que l'on définisse
