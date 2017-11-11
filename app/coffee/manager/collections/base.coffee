class Collection extends SimpleCollection
	_bddMessages:null
	fetch: ->
		if @url?
			$.ajax({
				dataType:"json"
				method:"GET"
				url:@url
			}).done(@fetchSuccessCB).fail(@fetchErrorCB)
		else
			$.get("./action.php?action=#{@name}List", null, @fetchCB, "json")

	fetchSuccessCB: (data) =>
		@parse data
		@triggerEvent "fetch"

	fetchErrorCB: (data) =>
		switch data.status
			when 401
				# connexion requise
				Controller.uLog.on {
					type:"connexion"
					cb:() => @saveRequest()
				}
				new VConnexion { reconnexion:true, container:"modalContent" }
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.");
			when 404
				alert("Vous essayer de modifier un item qui n'existe pas dans la base de données.");
			when 422
				alert("Données invalides.");
			else
				alert("Erreur inconnue.")

	fetchCB: (data) =>
		@setBddMessages data.messages
		unless data.error?
			@parse data
			@triggerEvent "fetch"
	add: (data,init=null) ->
		mod = new @model(init,@)
		mod.on {type:"change", cb:@addCB}
		mod.save data
	addCB: (item) =>
		@push item
		@triggerEvent "add", [item]
	setBddMessages: (messages) ->
		if messages? then @_bddMessages = messages
	bddMessages: ->
		if @_bddMessages? then @_bddMessages
		else []
	on: (ev) -> @events.push ev
	triggerEvent: (type, params=[@]) ->
		i=0
		while (i<@events.length)
			if @events[i].type is type
				if @events[i].obj? then @events[i].cb? @events[i].obj, params...
				else @events[i].cb? params...
				closeModal @events[i].modal
				if @events[i].url? then pushUrlInHistory @events[i].url
				if not(@events[i].forever) then @events.splice(i,1) # evenements once par défaut
				else i++
			else i++
