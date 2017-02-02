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
		@a = @data.answers
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
	run: (upBDD) -> @parent?.run(upBDD)
	verification: (name, tag, user, goodObject, bareme, params) ->
		output = mM.verification(user,goodObject,params)
		output.tag = tag
		output.name = name
		@data.note += output.ponderation*bareme
		output
	helper_disp_inputs: (title,text,inputs_list,aide,touches) ->
		# params :
		# title = String
		# text = String => envoyé comme texte de présentation, html non echappé
		# inputs_list = [{tag, }]
		# aide = ["it1", "it2", ...]
		# clavier = ["sqrt", "pi", "sqr", "empty", objet{name, title, tag, pre, post, recouvre}]
		@iList = inputs_list # Lien nécessaire pour la validation de la forme
		clavier = null
		if touches?
			clavier=[]
			for touche in touches
				switch
					when touche is "infini" then clavier.push {name:"infty-button", title:"Infini", tag:"$\\infty$"}
					when touche is "sqrt" then clavier.push {name:"sqrt-button", title:"Racine carrée", tag:"$\\sqrt{x}$"}
					when touche is "pi" then clavier.push {name:"pi-button", title:"Pi", tag:"$\\pi$"}
					when touche is "sqr" then clavier.push {name:"sqr-button", title:"Carré", tag:"$.^2$"}
					when touche is "x2" then clavier.push {name:"x2-button", title:"x carré", tag:"$x^2$"}
					when touche is "empty" then clavier.push {name:"empty-button", title:"Ensemble vide", tag:"$\\varnothing$"}
					when typeof touche is "object" then clavier.push {name:touche.name, title:touche.title, tag:touche.tag}
		inputs=[]
		for item in inputs_list
			inputs.push {tag:item.tag,description:item.description,name:item.name, large:(item.large is true)}

		if aide?
			help_zone = "#{@divId}_aide"
			help_html = Handlebars.templates.help(aide)
		else help_zone = help_html = null
		context = {
			title:title
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
		if text?
			# On transmet soit un simple texte, soit une structure plus complexe sous forme d'un tableau
			if isArray text then context.zones = text.concat(context.zones)
			else context.zones.unshift { body:"texte", html:text }
		@container.html Handlebars.templates.std_panel context
		$("#form#{@divId}").on 'submit', (event) =>
			aList = $(event.target).serializeObject()
			for item in @iList
				@a[item.name] = aList[item.name]
				if item.moduloKey
					@a[item.name] = @a[item.name].replace item.moduloKey, "#"
			@run true
			false
		if clavier isnt null
			$inputs_List = ($("input[name='#{item.name}']",@container) for item in inputs_list)
			@gc = new GestClavier $inputs_List...
			for touche in touches
				switch
					when touche is "infini" then $("button[name='infty-button']",@container).on 'click', (event) => @gc.clavier("∞","",true)
					when touche is "sqrt" then $("button[name='sqrt-button']",@container).on 'click', (event) => @gc.clavier("sqrt(",")",false)
					when touche is "pi" then $("button[name='pi-button']",@container).on 'click', (event) => @gc.clavier("π","",true)
					when touche is "sqr" then $("button[name='sqr-button']",@container).on 'click', (event) => @gc.clavier("","^2",false)
					when touche is "x2" then $("button[name='x2-button']",@container).on 'click', (event) => @gc.clavier("x^2","",true)
					when touche is "empty" then $("button[name='empty-button']",@container).on 'click', (event) => @gc.clavier("∅","",true)
					when typeof touche is "object" then $("button[name='#{touche.name}']",@container).on 'click', (event) => @gc.clavier(touche.pre,touche.post,touche.recouvre)
		if inputs_list.length>0 then $("input[name='#{inputs_list[0].name}']",@container).focus()

class BListe extends Brique
	default: () ->  {liste:[], title:"titre ?"}
	go: ->
		for item in @config.liste
			if (typeof @a[item.name] is "undefined") then return false
		true
	ask: ->
		@helper_disp_inputs(@config.title,@config.text,@config.liste,@config.aide,@config.touches)
	ver: ->
		bar = @bareme/Math.max(@config.liste.length,1)
		values = ( @verification(item.name,item.tag, @a[item.name], item.good, bar, item.params) for item in @config.liste)
		@container.html Handlebars.templates.verif {values:values, title:@config.title, text:@config.cor_text}
		for it,i in @config.liste
			if it.params?.customTemplate?
				$("[name='#{it.name}']",@container).append Handlebars.templates.cor_custom values[i]
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
			@data.note = @bareme
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
class BSolutions extends Brique
	# moduloKey permet de remplacer par exemple le k de 2kpi par #
	default: () ->  {aKey:"solutions", title:"Solution(s)", solutions:[]}
	go: -> (typeof @a[@config.aKey] isnt "undefined")
	ask: ->
		unless @config.touches? then @config.touches=[]
		inputs_list = [{tag:"Solution(s)", description:"Solution(s)", name:@config.aKey, large:true, moduloKey:@config.moduloKey}]
		@config.touches.unshift "empty"
		text = "Vous devez donner la ou les solutions de cette équations, si elles existent. S'il n'y a pas de solution, écrivez $\\varnothing$. s'il y a plusieurs solutions, séparez-les avec ;"
		@helper_disp_inputs(@config.title,text,inputs_list,@config.aide,@config.touches)
	ver: ->
		if @config.solutions.length is 0 then solutionsTex = "\\varnothing"
		else solutionsTex = "\\left\\lbrace "+(x.tex() for x in @config.solutions).join(";")+"\\right\\rbrace"
		if @a[@config.aKey] is "∅"
			# L'utilisateur a répondu ensemble vide
			context = { correction:true, userIsEmpty:true, goodIsntEmpty:@config.solutions.length isnt 0, lefts: (l.tex() for l in @config.solutions).join(" ; ") }
			if @config.solutions.length is 0 then @data.note += @bareme
			else context.good = solutionsTex
		else
			# On considère que l'on a une série de valeurs
			users = (str for str in @a[@config.aKey].split ";" when str isnt "")
			N = Math.max @config.solutions.length, users.length
			if N is 0 then bareme = 0
			else bareme = @bareme/N
			sorted = mM.tri users,@config.solutions, "number"
			list=[]
			goodValues = []
			bads = []
			for sol,i in sorted.closests
				list.push sol.user.tex()
				if sol.good?
					infoUser = new Parser sol.user, {type:"number"}
					verif = @verification @config.aKey,"", infoUser, sol.good,bareme,{formes:"RACINE"}
					if verif.erreur.exact or verif.approximation then goodValues.push verif
					else
						bads.push infoUser.tex
						sorted.lefts.push sol.good
				else bads.push sol.user.tex()
			context = { users:list.join(" ; "), goodValues:goodValues, bads:bads.join(" ; "), lefts:(l.tex() for l in sorted.lefts).join(" ; "), goodIsEmpty:@config.solutions.length is 0 }
		@container.html Handlebars.templates.std_panel {
			title: @config.title+" : $\\mathcal{S}= #{solutionsTex}$"
			zones: [{
				list:"correction"
				html:Handlebars.templates.cor_solutions context
			}]
		}
class BEquations extends Brique
	# L'utilisateur fournit une ou plusieurs équations séparées par ;
	default: () ->  {aKey:"equations", title:"Équation(s)", equations:[], text:""}
	go: -> (typeof @a[@config.aKey] isnt "undefined")
	ask: ->
		unless @config.touches? then @config.touches=[]
		inputs_list = [ {tag:"Équation(s)", description:"Équation(s)", name:@config.aKey, large:true} ]
		@config.touches.unshift "empty"
		@config.text = @config.text+"<p>S'il y a plusieurs réponses, séparez-les avec ; S'il n'y a aucune réponse, répondez $\\varnothing$</p>"
		@helper_disp_inputs(@config.title, @config.text,inputs_list,@config.aide,@config.touches)
	ver: ->
		if @config.equations.length is 0 then solutionsTex = "Aucune équation"
		else solutionsTex = " : $#{(eq.tex() for eq in @config.equations).join(';')}$"
		if @a[@config.aKey] is "∅"
			# L'utilisateur a répondu ensemble vide
			context = {
				users: "\\varnothing"
				userIsEmpty:true
				goodValues:null
				bads:null
				goodIsEmpty:@config.solutions.length is 0
				lefts: (l.tex() for l in @config.solutions).join(" ; ")
			}
			if @config.solutions.length is 0 then @data.note += @bareme
		else
			# On fait un tableau avec la réponse utilisateur
			users = (str for str in @a[@config.aKey].split ";" when str isnt "")
			N = Math.max @config.equations.length, users.length
			if N is 0 then bareme = 0
			else bareme = @bareme/N
			sorted = mM.tri users,@config.equations, "equation"
			list=[]
			goodValues = []
			bads = []
			for sol,i in sorted.closests
				list.push sol.info.tex
				if sol.good?
					# on a un user associé un good, mais est-il exact ?
					if sol.d is 0
						goodValues.push sol
						@data.note += bareme
					else
						bads.push sol.info.tex
						sorted.lefts.push sol.good
				else bads.push sol.info.tex
			context = {
				users:list.join(" ; ")
				goodValues:goodValues
				bads:bads.join(" ; ")
				lefts:(l.tex() for l in sorted.lefts).join(" ; ")
			}
		@container.html Handlebars.templates.std_panel {
			title: @config.title+"#{solutionsTex}"
			zones: [{
				list:"correction"
				html:Handlebars.templates.cor_equations context
			}]
		}

class BEnsemble extends Brique
	default: () ->  { aKey:"ensemble", title:"Ensemble solution", ensemble_solution:mM.ensemble.vide() }
	go: -> (typeof @a[@config.aKey] isnt "undefined")
	ask: ->
		@container.html Handlebars.templates.std_panel {
			title:@config.title
			focus:true
			zones: [{
				body:"champ"
				html:Handlebars.templates.std_form {
					id:"form#{@divId}"
					inputs:[
						{
							tag:"$\\mathcal{S}=$"
							description:"Ensemble solution"
							name:"ensemble"
						}, {
							clavier:[
								{name:"btnU", title:"Union", tag:"$\\cup$"},
								{name:"btnInter", title:"Intersection", tag:"$\\cap$"},
								{name:"btnInf", title:"Infini", tag:"$\\infty$"},
								{name:"btnEmpty", title:"Ensemble vide", tag:"$\\varnothing$"},
								{name:"btnReels", title:"Ensemble des réels", tag:"$\\mathbb{R}$"}
							]
						}
					]
				}
			}]
		}
		@gc = new GestClavier($("input[name='ensemble']"))
		$("button[name='btnU']",@container).on 'click', (event) => @gc.clavier("∪","",true)
		$("button[name='btnInter']",@container).on 'click', (event) => @gc.clavier("∩","",true)
		$("button[name='btnInf']",@container).on 'click', (event) => @gc.clavier("∞","",true)
		$("button[name='btnEmpty']",@container).on 'click', (event) => @gc.clavier("∅","",true)
		$("button[name='btnReels']",@container).on 'click', (event) => @gc.clavier("ℝ","",true)
		$("#form#{@divId}").on 'submit', (event) =>
			@a[@config.aKey] = $(event.target).serializeArray()[0].value
			@run true
			false
		$("input[name='ensemble']",@container).focus()
	ver: ->
		user = new Parser @a[@config.aKey], {type:"ensemble"}
		solTex = @config.ensemble_solution.tex()
		if @config.ensemble_solution.isEqual(user.object)
			@data.note+=@bareme
			out = [{ text:"Vous avez donné $\\mathcal{S}= #{ user.tex }$. Bonne réponse.", color:"ok"}]
		else
			out = [
				{ text:"Vous avez donné $\\mathcal{S}= #{ user.tex }$.", color:"error" }
				{ text:"La bonne réponse était $\\mathcal{S}= #{solTex}$.", color:"error" }
			]
		@container.html(Handlebars.templates.std_panel({
			title:"#{@config.title} : $\\mathcal{S} = #{ solTex }$"
			zones:[{
				list:"correction"
				html:Handlebars.templates.listItem out
			}]
		}))
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
