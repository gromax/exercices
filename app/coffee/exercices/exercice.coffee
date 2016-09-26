
# helpers functions
colors = [
	{ tex:"red", html:"#ff0000" }
	{ tex:"JungleGreen", html:"#347c2c" }
	{ tex:"Violet", html:"#8d38c9" }
	{ tex:"Orange", html:"#ffa500" }
	{ tex:"blue", html:"#0000ff" }
	{ tex:"gray", html:"#808080" }
	{ tex:"Thistle", html:"#d2b9d3" }
	{ tex:"Mahogany", html:"#c04000" }
	{ tex:"yellow", html:"#ffff00" }
	{ tex:"CornflowerBlue", html:"#6495ed" }
]
h_ineqSymb = ["<", ">", "\\leqslant", "\\geqslant"]
h_genId = () -> Math.floor(Math.random() * 10000)
h_init = (inpName,saveObj,_min,_max, force=false) ->
	# prend inp s'il est défini, sinon un entier alea entre _min et _max
	if (not force) and (saveObj[inpName])? then saveObj[inpName] = Number saveObj[inpName]
	else saveObj[inpName] = Proba.aleaEntreBornes(_min,_max)
h_random_order = (n,def) ->
	# Donne un tableau [1..n] mais ordonné au hasard
	# Si def est donné, sous forme de texte, on prend default
	if def?
		# default doit être un string
		(Number c for c in def)
	else
		Tools.arrayShuffle([0..n-1])
h_clone = (obj) ->
	if (typeof obj isnt "object") or (obj is null) then return obj
	out = {}
	out[key] = h_clone(obj[key]) for key of obj
	out

# helper handlebar
#Handlebars.registerHelper 'colorListItem', (color)->
#	switch color
#		when "error" then "list-group-item-danger"
#		when "good" then "list-group-item-success"
#		when "info" then "list-group-item-info"
#		else ""

class @Exercice
	@liste: [] # Liste qui se complète avec les fichiers exercices
	@getModel: (idExo) ->
		idExo = Number idExo
		(exo for exo in @liste when exo.id is idExo)[0]
	@read_options: (params,liste) ->
		# params est l'objet d'options fournis par l'utilisateur, éventuellement vide ou pouvant contenir des champs inutiles
		# liste est l'objet, s'il est défini, du model donnant la liste des options possibles, avec leur valeurs par défaut
		unless liste? then return {}
		out = h_clone liste
		unless params? then params = {}
		for key of out
			if params[key]? then out[key].value = Number params[key]
			else out[key].value = out[key].def
		out
	constructor: (params) ->
		# paramètres utiles :
		# idE : id de l'exercice, contenu dans exoFiche.idE
		# oEF : objet d'association entre exercice et devior
		# aUF : id de l'association d'un élève avec un devoir
		config = Tools.merge { divId:0 },params
		@divId = config.divId
		@oEF = config.oEF
		@aUF = config.aUF
		unless (@model = config.model or @constructor.getModel(config.idE ? @oEF?.idE))?
			# On envoie un modèle erreur
			@model = {
				title: "Exercice inexistant"
				init: (data)->
					[
						new BEnonce({
							title:"Erreur !"
							zones:[{body:"enonce", "<p>L'exercice que vous avez choisi n'existe pas !</p>"}]
						})
					]
			}
		@data = { options:Exercice.read_options(params.oEF?.options, @model.options)}
	init: (note) ->
		if note?
			inputs = note.inputs
			answers = note.answers
		else
			inputs = {}
			answers = {}
		@data = { inputs:inputs, answers:answers, note:0, options:@data.options, noteObject:note, divId:@divId, isAdmin:Controller?.uLog.isAdmin }
		@finished = false
		@stages = @model.init(@data)
		for stg,i in @stages
			stg.parent = @
			stg.divId = @divId+"s"+i
		@title = @data.title or @model.title # Le title peut-être changé en fonction des options
		@
	toString: -> @model.title
	refreshDisplay: ->
		#if @finished then @displayNote()
		@displayNote()
		$('[data-toggle="tooltip"]').tooltip()
		MathJax.Hub.Queue(["Typeset",MathJax.Hub])
	displayNote: ->
		if @oEF?
			note = Math.round(@data.note)
			if Controller.uLog.isEleve
				todo = @oEF.num
				done = Controller.uLog.notes()?.filteredList({aEF:@oEF.id, aUF:@aUF}).length
				$("span[name='doneCounter']",@container).html(done) # Met à jour le titre
				context = {note:note, moyenne:@oEF.moyenne(Controller.uLog,@aUF), todo: todo, todoOnce: todo is 1, done:done, doneOnce: done is 1, reload:true, finished:@finished}
			else
				context = {note:note, todoOnce: true, doneOnce: true, finished:@finished}
				if @data.noteObject? and @data.noteObject.note isnt note then context.noteInBDD=@data.noteObject.note
			$("#note_#{@divId}").html Handlebars.templates.note context
	#----------------------------------------------------
	#--------- exécution d'un exercice ------------------
	#----------------------------------------------------
	updateBDD: (force=false)->
		# On ne sauvegarde que si c'est un élève connecté
		if Controller.uLog.isEleve or (force and @data.noteObject?)
			if @data.noteObject?
				@data.noteObject.save { inputs:@data.inputs, answers:@data.answers, note:Math.round(@data.note), finished:@finished }, true
			else if @oEF?
				@data.noteObject = Controller.uLog.pushNote { aEF:@oEF.id, aUF:@aUF }
				@data.noteObject.save { inputs:@data.inputs, answers:@data.answers, note:Math.round(@data.note), finished:@finished }, true
	finish: -> @finished = true
	run: (upBdd) ->
		go = true
		while (@stages.length>0) and go
			# On peut mettre d'autres items dans la liste, comme l'énoncé ou un graphique
			currentStage = @stages[0]
			if currentStage instanceof Brique
				currentStage.initContainer()
				if ( go = go and currentStage.go() )
					@stages.shift()
					currentStage.ver()
					if currentStage.config.repeat
						@stages.unshift currentStage
						go = false
				else currentStage.ask()
			else @stages.shift()
		if @stages.length is 0 then @finish()
		if upBdd then @updateBDD()
		@refreshDisplay()
	makeContainers: ->
		# Création des containers des différentes étapes
		# Au début, simples panneaux d'attente ou énoncé, ou graphique
		# retourne le html à insérer
		zones = {}
		for stg,i in @stages
			zone_id = stg.config.zone ? "default_zone"
			zone_html = zones[zone_id] ? ""
			zones[zone_id] = zone_html+stg.makeContainer()
		html_out = zones.default_zone ? ""
		delete zones.default_zone
		if @model.template? and (HTemplate = Handlebars.templates[@model.template])?
			html_out += HTemplate zones
		else html_out += zones[zone] for zone of zones
		html_out
	optionsForm:(idForm)->
	reloadOptions:(optionsArray) ->
		for it in optionsArray
			@data.options[it.name]?.value = Number it.value
		@init null
	#----------------------------------------------------
	#--------- production d'un fichier tex --------------
	#----------------------------------------------------
	slide: (data) -> @model?.side?(data) or ""
