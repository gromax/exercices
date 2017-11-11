class MFiche extends Model
	_glyph: "glyphicon-file"
	_name: "fiche"
	exercices: null # Liste des exercices dans la fiche
	_fetched:false # Toutes les informations ne sont pas chargées
	urlRoot:"./api/fiches"
	enteteForMessages: -> "<b>#{@nom} :</b> "
	defaultValues: -> { nom:"", description:"", idOwner: null, date:today(), visible:false, actif:false, ownerName:Controller.uLog.nom }
	toString: -> "["+@id+"]"+@nom
	parse: ->
		if @id? then @id = Number @id
		if @idOwner? then @idOwner = Number @idOwner
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
		@visible = (@visible is "1") or (@visible is true)
		@actif = (@actif is "1") or (@actif is true)
		if Controller.uLog.isEleve then @_fetched = true
		@
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		if mods.nom? then toBDD.nom = mods.nom
		if mods.description? then toBDD.description = mods.description
		if mods.visible?
			if (mods.visible or (mods.visible is "1")) then toBDD.visible = "1"
			else toBDD.visible = "0"
		if mods.actif?
			if (mods.actif or (mods.actif is "1")) then toBDD.actif = "1"
			else toBDD.actif = "0"
		toBDD
	load: (eventObject) ->
		eventObject.type = "load"
		@on eventObject
		@getFullInfos()
	getFullInfos: ->
		# Récupère les exercices associés à la fiche
		if not @_fetched # avec un élève tout est chargé au début
			$.ajax({
				dataType:"json"
				method:"GET"
				url:@urlRoot+"/"+@id+"/full"
			}).done(@fetchFullInfosSuccessCB).fail(@fetchFullInfosErrorCB)
		else @triggerEvent "load"
	fetchFullInfosSuccessCB: (data)=>
		item.idFiche = @id for item in data.eleves
		Controller.uLog.UFlist.parse data.eleves
		@_fetched = true
		@exercices = new CExosFiche data.exercices, Controller.uLog.exercices, @
		# Chargement des notes
		if data.faits?
			current_idUser=null
			for item in data.faits
				idUser = Number item.idUser
				if current_idUser isnt idUser
					user=Controller.uLog.users.get(idUser)
					current_idUser = idUser
				user?.pushNote(item)
		if data.exams? then @exams = new CExams data.exams, @
		@triggerEvent "load"
	fetchFullInfosErrorCB: (data)=>
		switch data.status
			when 401
				alert("Connexion requise.");
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.");
			when 404
				alert("Vous essayer de modifier un item qui n'existe pas dans la base de données.");
			else
				alert("Erreur inconnue.")
	pushExoFiche: (exofiche) ->
		unless @exercices? then @exercices = new CExosFiche null,@parent.exercices,@
		@exercices.push exofiche
	toNewExam: ->
		# Produit un tableau de data pour l'instance d'un nouvel exam
		( exo.toNewExam() for exo in @exercices.liste() )
	moyenne: (user) ->
		if @exercices?
			totalCoeff = 0
			total = 0
			for exo in @exercices.liste()
				total += exo.moyenne(user)*exo.coeff
				totalCoeff += exo.coeff
			@_pasnote = (totalCoeff is 0)
			if totalCoeff is 0 then return NaN
			else return Math.round total/totalCoeff
		else return NaN
	update: (config)->
		@_moyenne = @moyenne config?.user
	match: (filter) -> (not filter.doneBy?) #or (@_eleves? and @hasToBeDoneBy(filter.doneBy))
	postDelete: -> Controller.uLog.UFlist.remove({idFiche:@id})
