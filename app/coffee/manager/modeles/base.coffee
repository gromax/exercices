class Model extends SimpleModel
	events:null # On ne peut pas initialiser le tableau ici, autrement il est commun à tous les objets !
	pending_save:null
	showSuccessMessages:true
	# Les enfants doivent contenir :
	# enteteForMessages()
	# _name
	# bddJSON

	constructor: (json, parent) ->
		@events=[]
		super(json, parent)

	on: (ev) -> @events.push ev

	triggerEvent: (type, params=[@]) ->
		i=0
		while (i<@events.length)
			if @events[i].type is type
				if @events[i].obj? then @events[i].cb? @events[i].obj, params...
				else @events[i].cb? params...
				if @events[i].modal then closeModal()
				if @events[i].url? then pushUrlInHistory @events[i].url
				if not(@events[i].forever) then @events.splice(i,1) # evenements once par défaut
				else i++
			else i++

	save: (json,force=false) ->
		if @pending_save is null
			@pending_save = @bddJSON(json)
			# Le flag force change les entrées de l'item avant que la bdd ne réponde
			if force
				@set @pending_save
				@parse()
			# Prise en compte du urlRoot
			if @urlRoot? then @saveRequest()
			else
				# Ancienne version
				$.post("./action.php?action=#{@_name}Save", @pending_save, @saveCB, "json")

	saveRequest:() ->
		if @id?
			# Il s'agit d'une mise à jour => PUT
			$.ajax({
				data:JSON.stringify(@pending_save)
				dataType:"json"
				method:"PUT"
				url:@urlRoot+"/"+@id
			}).done(@saveSuccessCB).fail(@saveErrorCB)
		else
			# Il s'agit d'une création => POST
			$.ajax({
				data:JSON.stringify(@pending_save)
				dataType:"json"
				method:"POST"
				url:@urlRoot
			}).done(@saveSuccessCB).fail(@saveErrorCB)

	saveCB: (data) =>
		# Si tout se passe bien, je pourrais supprimer cette fonction
		if data.error
			if data.unlogged
				Controller.uLog.on {
					type:"connexion"
					cb:() => $.post("./action.php?action=#{@_name}Save", @pending_save, @saveCB, "json")
				}
				new VConnexion { reconnexion:true, container:"modalContent" }
			else
				Controller.errorMessagesList data.messages, @enteteForMessages(), @_glyph
				@pending_save = null
		else
			if data.id? then @pending_save.id = data.id
			@set @pending_save
			@parse()
			@pending_save = null
			@triggerEvent "change"
			if @showSuccessMessages then Controller.notyMessage @enteteForMessages()+"Succès de la modification.", "success", @_glyph

	saveSuccessCB: (data) =>
		@set data
		@parse()
		@pending_save = null
		@triggerEvent "change"

	saveErrorCB: (data) =>
		switch data.status
			when 401
				# connexion requise
				console.log "erreur 401"
				Controller.uLog.on {
					type:"connexion"
					cb:() => @saveRequest()
				}
				new VConnexion { reconnexion:true, container:"#modalContent" }
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.")
				@pending_save = null
			when 404
				alert("Vous essayer de modifier un item qui n'existe pas dans la base de données.")
				@pending_save = null
			when 422
				alert("Données invalides.")
				@pending_save = null
			else
				alert("Erreur inconnue.")
				@pending_save = null

	delete: ->
		if @urlRoot?
			# Il s'agit d'une suppression => DELETE
			@deleteRequest()
		else
			$.post("./action.php?action=#{@_name}Delete", { id:@id }, @deleteCB, "json")

	deleteRequest: ->
		$.ajax({
			dataType:"json"
			method:"DELETE"
			url:@urlRoot+"/"+@id
		}).done(@deleteSuccessCB).fail(@deleteErrorCB)

	deleteCB: (data) =>
		# Ancienne version
		if data.error
			Controller.errorMessagesList data.messages, @enteteForMessages(), @_glyph
		else
			@parent.remove @
			@postDelete?() #Éventuels traitement suivant une suppression
			@triggerEvent "delete"
			if @showSuccessMessages then Controller.notyMessage @enteteForMessages()+"Succès de la suppression.", "success", @_glyph

	deleteSuccessCB: (data) =>
		@parent.remove @
		@postDelete?() #Éventuels traitement suivant une suppression
		@triggerEvent "delete"

	deleteErrorCB: (data) =>
		switch data.status
			when 401
				# connexion requise
				Controller.uLog.on {
					type:"connexion"
					cb:() => @deleteRequest()
				}
				new VConnexion { reconnexion:true, container:"modalContent" }
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.");
			when 404
				alert("Vous essayer de supprimer un item qui n'existe pas dans la base de données.");
			when 422
				alert("Données invalides.");
			else
				alert("Erreur inconnue.")
