class MCon extends Model
	_glyph: "glyphicon-off"
	_name: "con"
	urlRoot:"./api/cons"
	parse: ->
		if @id? then @id = Number @id
		if @date?
			jour = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$3/$2/$1"
			heure = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$4:$5:$6"
			@dateFr = "#{jour} #{heure}"
		else @date = currentDate()
		@success = (@success is "1") or (@success is true)
		if @identifiant?
			@user = Controller.uLog.users.getByField("email",@identifiant)
		@
	bddJSON: (mods) -> {}
	enteteForMessages: -> "<b>Connexion @#{@id} :</b> "
	defaultValues: -> {  }
