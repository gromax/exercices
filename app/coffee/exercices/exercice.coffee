
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
		# options : transmis directement
		# model : transmis directement
		config = mergeObj { divId:0 },params
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
		@data = { options:Exercice.read_options(params.oEF?.options or params.options, @model.options)}
	note: -> @data.noteObject
	init: (obj) ->
		note = null
		inputs = {}
		answers = {}
		if obj?
			if obj.note?
				note = obj.note
				inputs = obj.note.inputs
				answers = obj.note.answers
			else if obj.inputs? then inputs = obj.inputs
		@data = { inputs:inputs, answers:answers, note:0, options:@data.options, noteObject:note, divId:@divId, isAdmin:Controller?.uLog.isAdmin }
		@finished = false
		@stages = @model.init(@data)
		baremeTotal = 0
		for stg,i in @stages
			stg.parent = @
			stg.divId = @divId+"s"+i
			# On vérifie le bareme total
			if stg.bareme? then baremeTotal+=stg.bareme
		if (baremeTotal isnt 0) and (baremeTotal isnt 100)
			coeff = 100/baremeTotal
			baremeTotal = 100
			last = null
			for stg in @stages
				if stg.bareme?
					stg.bareme = Math.round(stg.bareme*coeff)
					baremeTotal -= stg.bareme
					last = stg
			if baremeTotal isnt null
				# Il reste un relicat dû aux arrondis
				last.bareme += baremeTotal
		@title = @data.title or @model.title # Le title peut-être changé en fonction des options
		@
	toString: -> @model.title
	refreshDisplay: ->
		#if @finished then @displayNote()
		@displayNote()
		$('[data-toggle="tooltip"]').tooltip()
		$('[data-toggle="popover"]').popover()
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
	updateBDD: ->
		switch
			when @data.noteObject?
				@data.noteObject.save { inputs:@data.inputs, answers:@data.answers, note:Math.round(@data.note), finished:@finished }, true
			when @oEF?
				@data.noteObject = Controller.uLog.pushNote { aEF:@oEF.id, aUF:@aUF }
				@data.noteObject.save { inputs:@data.inputs, answers:@data.answers, note:Math.round(@data.note), finished:@finished }, true
	finish: -> @finished = true
	run: (upBdd) ->
		# @stages contient des briques qui sont des éléments d'énoncés et des questions
		go = true
		# go : parcourir les différentes briques.
		# Dès qu'on rencontre une brique attendant des réponses qui n'existe pas encore
		# go passe à false
		while (@stages.length>0) and go
			currentStage = @stages[0]
			if currentStage instanceof Brique
				currentStage.initContainer()
				# La fonction Brique.go() d'une brique permet de savoir s'il y a des réponses attendues.
				if ( go = go and currentStage.go() )
					# La présente brique a déjà reçu ses réponses, on peut donc la dépiler et la vérifier ->Brique.ver()
					@stages.shift()
					currentStage.ver()
					# Certaines briques se répètent (permettent d'afiner la réponse)
					# Dans ce cas, on rempile la brique et on stoppe le déroulement (false->go)
					if currentStage.config.repeat
						@stages.unshift currentStage
						go = false
				else currentStage.ask()
				# On en est arrivé à une brique à laquelle il faut répondre : fonction Brique.ask()
			else @stages.shift()
			# L'item n'est pas une brique, ça ne devrait pas arriver
		# On a vider la pile de briques, l'exercice est terminé -> Fonction finish()
		if @stages.length is 0 then @finish()
		# La base de données n'est remise à jour que s'il s'agit d'une version notée de l'exercice
		# Et quand run() s'est déclenché suite à une réponse utilisateur.
		# Lors du premier affichage de l'exercice, aucune raison de remettre à jour la BDD
		if upBdd and Controller.uLog.isEleve then @updateBDD()
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

