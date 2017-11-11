class MExam extends Model
	_glyph: "glyphicon-blackboard"
	_name: "exam"
	_nExos: null
	urlRoot:"./api/exams"
	enteteForMessages: -> "<b>Examen @#{@id} :</b> "
	defaultValues: -> { nom:"Nouvel exam" }
	parse: ->
		if @id? then @id = Number @id
		if @idFiche? then @idFiche = Number @idFiche
		else @idFiche = @parent?.parent?.id
		if typeof @data is "string" then @data = JSON.parse @data
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
		else @date = currentDate()
		@locked = (@locked is "1") or (@locked is true)
		@
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		toBDD.idFiche = @parent.parent.id
		if mods.nom? then toBDD.nom = mods.nom
		if mods.data? then toBDD.data = JSON.stringify mods.data
		if mods.locked?
			if (mods.locked or (mods.locked is "1")) then toBDD.locked = "1"
			else toBDD.locked = "0"
		toBDD
	toTex: ()->
		texList = []
		for item in @data
			idE = item.idE
			model = Controller.uLog.exercices.get(idE)
			exo = new Exercice { model: model, options:item.options }
			texList = texList.concat(model.tex?( ( exo.init({ inputs:inp }).data for inp in item.inputs)) or [])
		Handlebars.templates.tex_container { items:texList, id:@id, nom:@nom }
	fiche: -> @parent.parent
	nExos: ->
		if @_nExos is null
			@_nExos = 0
			@_nExos += item.inputs.length for item in @data
		@_nExos
	getExo: (indice) ->
		if indice>=@nExos() then return null
		indiceExo = 0
		i = indice
		while (indiceExo<@data.length) and (i>=(l=@data[indiceExo].inputs.length))
			i -=l
			indiceExo++
		{
			exam:@
			indice:indice
			indiceParent:indiceExo
			indiceEnfant:i
			options:@data[indiceExo].options
			idE:@data[indiceExo].idE
			inputs:@data[indiceExo].inputs[i]
			next:indice<@nExos()-1 # il existe un exercice après
			prev:indice>0 # Il existe un exercice avant
			update: (inp) ->
				if inp?
					@exam.data[@indiceParent].inputs[@indiceEnfant] = inp
					@exam.save { data:@exam.data }
		}
