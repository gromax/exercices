class MExoFiche extends Model
	_glyph: "glyphicon-edit"
	_name: "exofiche"
	urlRoot:"./api/exosfiche"
	constructor: (json, parent) ->
		#@mesNotes = []
		super(json,parent)
	enteteForMessages: -> "<b>#{@title} :</b> "
	defaultValues: -> { title:"", description:"", coeff:1, num:1 }
	parse: ->
		if @id? then @id = Number @id
		if @idFiche? then @idFiche = Number @idFiche
		else @idFiche = @parent?.parent?.id
		if @coeff? then @coeff = Number @coeff
		if @num? then @num = Number @num
		if @options then @options = JSON.parse @options
		if @idE?
			@idE = Number @idE
			@exercice = Controller.uLog.exercices.get @idE
			@title = @exercice?.title
			@description = @exercice?.description
		@
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		toBDD.idFiche = @parent.parent.id
		if mods.idE? then toBDD.idE = mods.idE
		if mods.coeff? then toBDD.coeff = mods.coeff
		if mods.options? then toBDD.options = JSON.stringify mods.options
		if mods.num? then toBDD.num = mods.num
		toBDD
	match: (filter) -> filter.reg?.test(@title+" "+@description) isnt false
	toNewExam: ->
		# Produit une instance des exercices pour un nouvel exam
		exo = new Exercice { model:@exercice, options:@options }
		{ idE:@idE, options:@options, inputs:(exo.init().data.inputs for i in [1..@num]) }
	moyenne: (user,aUF) ->
		if user? then notes = user.notes().liste { aEF:@id, aUF:aUF }
		else notes=Controller.uLog.notes().liste { aEF:@id, aUF:aUF }
		coeff = 1
		total = 0
		totalCoeff = 0
		i = @_done = notes.length
		seuil = i-@num
		while i>0
			if i <= seuil then coeff *= .8
			i--
			total+= notes[i].note*coeff
			totalCoeff += coeff
		return Math.round(total/Math.max(totalCoeff,@num))
	update: (config) ->
		if config? and config.aUF?
			@_moyenne = @moyenne config.user, config.aUF
			if @_moyenne<10 then @str_moyenne = "0"+@_moyenne
			else @str_moyenne = String @_moyenne
		else
			@_moyenne = 0
			@_done = 0
			@str_moyenne = "00"
	fiche: -> @parent.parent
