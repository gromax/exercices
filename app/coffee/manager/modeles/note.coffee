class MNote extends Model
	_name: "note"
	_exofiche: null # mémorisation de l'objet exofiche lié
	showSuccessMessages: false
	urlRoot:"./api/notes"
	enteteForMessages: -> ""
	defaultValues: -> { note:0, finished:false, inputs:{}, answers:{} }
	toString: -> "[#{@id}] Notes du #{@dateFr} à #{@hour}) : #{@note}%"
	parse: ->
		if @id? then @id = Number @id
		if @idUser? then @idUser = Number @idUser
		if @aEF? then @aEF = Number @aEF # id de l'assoc exercice-fiche
		if @aUF? then @aUF = Number @aUF # id de l'assoc user-fiche
		if @note? then @note = Number @note
		@finished = (@finished is "1") or (@finished is true)
		unless @date
			d= new Date()
			m = d.getMonth()+1
			if m<10 then m="0"+m
			@date = d.getFullYear()+"-"+m+"-"+d.getDate()+" "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds()
		@dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$3/$2/$1"
		@hour = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$4:$5:$6"
		if @inputs? and (typeof @inputs is "string")
			if @inputs is "" then @inputs = {}
			else @inputs = JSON.parse @inputs
		if @answers? and (typeof @answers is "string")
			if @answers is "" then @answers = {}
			else @answers = JSON.parse @answers
		@
	idFiche: ->
		unless @_idFiche? then @_idFiche = Controller.uLog.fiches?.getExoFiche(@aEF)?.idFiche
		@_idFiche
	exoFiche: ->
		if @_exofiche is null then @_exofiche = Controller.uLog.fiches.getExoFiche @aEF
		@_exofiche
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		else
			# En l'absence d'id, c'est une création en BDD et il faut préciser ces paramètres
			toBDD.aEF = @aEF or mods.aEF
			toBDD.aUF = @aUF or mods.aUF
		if mods.inputs? then toBDD.inputs = JSON.stringify mods.inputs
		if mods.answers? then toBDD.answers = JSON.stringify mods.answers
		if mods.note? then toBDD.note = mods.note
		if mods.finished?
			if mods.finished or (mods.finished is "1") then toBDD.finished = "1"
			else toBDD.finished = "0"
		toBDD
	match: (filter) -> not (filter.aEF? and (filter.aEF isnt @aEF)) and not (filter.idFiche? and (filter.idFiche isnt @idFiche())) and not (filter.finished? and (filter.finished isnt @finished)) and not (filter.aUF? and (filter.aUF isnt @aUF))
