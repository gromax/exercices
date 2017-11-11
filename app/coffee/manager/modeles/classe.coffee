class MClasse extends Model
	_glyph: "glyphicon-education"
	_name: "classe"
	urlRoot:"./api/classes"
	enteteForMessages: -> "<b>#{@nom} :</b> "
	defaultValues: -> { nom:"", ouverte:false, description:"", idOwner:null, pwd:"", date:today() }
	toString: -> "["+@id+"]"+@nom
	parse: ->
		if @id? then @id = Number @id
		@ouverte = (@ouverte is "1") or (@ouverte is true)
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
		if @owner? then @nomOwner = @owner.nom
		@
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		if mods.nom then toBDD.nom = mods.nom
		if mods.ouverte? and (mods.ouverte or (mods.ouverte is "1")) then toBDD.ouverte = "1"
		else toBDD.ouverte = "0"
		if mods.description? then toBDD.description = mods.description
		if mods.pwd? then toBDD.pwd = mods.pwd
		toBDD
	testMDP: (pwd) ->
		$.ajax({
			data:{ pwd:pwd }
			dataType:"json"
			method:"GET"
			url:@urlRoot+"/"+@id+"/test"
		}).done(@testMDPSuccessCB).fail(@testMDPErrorCB)
	testMDPSuccessCB: (data) =>
		@triggerEvent "testMDP"
	testMDPErrorCB: (data) =>
		Controller.errorMessagesList data.messages, "Inscription dans <b>#{@nom}</b> : ", @_glyph
	join: (userData) ->
		$.ajax({
			data:JSON.stringify(userData)
			dataType:"json"
			method:"POST"
			url:@urlRoot+"/"+@id+"/join"
		}).done(@joinSuccessCB).fail(@joinErrorCB)
	joinSuccessCB: (data) =>
		@triggerEvent "inscription", [@, data]
	joinErrorCB: (data) =>
		switch data.status
			when 401
				alert("Connexion requise.");
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.");
			when 404
				alert("Vous essayer de modifier un item qui n'existe pas dans la base de données.");
			when 422
				alert("Données invalides.");
			else
				alert("Erreur inconnue.")
