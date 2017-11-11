class MUser extends Model
	_glyph: "glyphicon-user"
	_name: "user"
	_notes:null
	_infosLoaded:false # garantit qu'on a bien toutes les infos pour cet utilisateur
	urlRoot:"./api/users"
	enteteForMessages: -> "<b>#{@} :</b> "
	defaultValues: -> { pseudo:"", nom: "", prenom:"", email:"", rank:"Off", locked:false }
	toString: -> "@#{@id} :[#{@nom} #{@prenom}]"
	fullName: (reverse=false) -> if reverse then @prenom+" "+@nom else @nom+" "+@prenom
	identifiant:-> if @isRoot then "root" else @email
	parse: ->
		if @id? then @id = Number @id
		if @idClasse? then @idClasse = Number @idClasse
		else @nomClasse = @rank
		@isRoot = (@rank is "Root")
		@isAdmin = (@rank is "Admin") or (@rank is "Root")
		@isEleve = (@rank is "Élève")
		@isProf =  (@rank is "Prof")
		@isOff = not ( @isAdmin or @isEleve or @isProf )
		if @date?
			@dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$3/$2/$1"
			@hour = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$4:$5:$6"
		@locked = (@locked is "1") or (@locked is true)
		@
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		if mods.locked?
			if (mods.locked or (mods.locked is "1")) then toBDD.locked = "1"
			else toBDD.locked = "0"
		if mods.pseudo? then toBDD.pseudo = mods.pseudo
		if mods.rank? then toBDD.rank = mods.rank
		if mods.nom? then toBDD.nom = mods.nom
		if mods.prenom? then toBDD.prenom = mods.prenom
		if mods.email? then toBDD.email = mods.email
		if mods.pwd? then toBDD.pwd = mods.pwd
		toBDD
	load: (eventObject) ->
		eventObject.type = "infos-fetched"
		@on eventObject
		@fetchFullInfos()
	classe: ->
		if not @isEleve then return
		if not(@_classe?)then @_classe  = Controller.uLog.classes?.get(@idClasse)
		@_classe
	match: (filter) -> (filter.reg?.test(@nom+" "+@prenom+" "+@classe+" "+@email+" "+@pseudo) isnt false) and ((filter.rank is @rank) or (typeof filter.rank is "undefined")) and ((filter.idClasse is @idClasse) or (not filter.idClasse?))
	pushNote: (note) ->
		if @_notes is null then @_notes = new CNotes null
		newNote = @_notes.push note
		return newNote
	notes_fetched: -> @_notes isnt null
	notes: ->
		unless @_notes? then @_notes = new CNotes null
		return @_notes
	fetchFullInfos: ->
		if @_infosLoaded then @triggerEvent "infos-fetched"
		else
			$.ajax({
				dataType:"json"
				method:"GET"
				url:@urlRoot+"/"+@id+"/notes"
			}).done(@fetchFullInfosSuccessCB).fail(@fetchFullInfosErrorCB)
	fetchFullInfosSuccessCB: (data) =>
		@fetchProcessing data
		@triggerEvent "infos-fetched"
	fetchFullInfosErrorCB: (data) =>
		switch data.status
			when 401
				alert("Connexion requise.");
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.");
			when 404
				alert("Vous essayer de modifier un item qui n'existe pas dans la base de données.");
			else
				alert("Erreur inconnue.")
	fetchProcessing:(data)->
		# Appelé lors du chargement initial d'un élève
		# ou lors du chargement d'un élève par un admin/prof
		@_infosLoaded = true
		@_notes = new CNotes data.faits
		if data.exosfiches? then CExosFiche.sortExosFiches data.exosfiches, Controller.uLog.fiches
		# Chargement des liens fiche / utilisateur
		item.idUser = @id for item in data.fichesAssoc
		Controller.uLog.UFlist.parse data.fichesAssoc
	postDelete: -> Controller.uLog.UFlist.remove({idUser:@id})
	update: (config) ->
		# On compte le nombre d'élément de l'association fiche-user
		if (idFiche=config?.idFiche? or config?.fiche?.id)
			@_nbUF = Controller.uLog.UFlist.filteredList({idUser:@id, idFiche:idFiche}).length
			@_UF_exists = (@_nbUF>0)
		else
			@_nbUF = null
			@_UF_exists = false
		if config?.oUF?
			@_noteUF = config.oUF.moyenne()
			if oUF_pasnote then @_noteUF = null
		else @_noteUF = null
	forgottenPwd:->
		$.ajax({
			dataType:"json"
			method:"POST"
			url:@urlRoot+"/"+@id+"/init"
		}).done(@forgottenPwdSuccessCB).fail(@forgottenPwdErrorCB)
	forgottenPwdSuccessCB: (data)=>
		@triggerEvent "forgotten",[data]
	forgottenPwdErrorCB: (data)->
		Controller.errorMessagesList data.messages, "Mot de passe oublié : "
