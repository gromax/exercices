class MAssoUF extends Model
	_name: "assoUF"
	showSuccessMessages: false
	urlRoot:"./api/assosUF"
	enteteForMessages: -> ""
	defaultValues: -> { actif:true }
	toString: -> "[#{@id}] Association #{@user()?.prenom} #{@user()?.nom} - #{@fiche()?.nom} (#{@dateFr})"
	parse: ->
		if @id? then @id = Number @id
		if @idUser? then @idUser = Number @idUser
		if @idFiche? then @idFiche = Number @idFiche
		@actif = (@actif is "1") or (@actif is true)
		unless @date
			d= new Date()
			m = d.getMonth()+1
			if m<10 then m="0"+m
			@date = d.getFullYear()+"-"+m+"-"+d.getDate()
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		else toBDD.date = @date
		if mods.idFiche?
			toBDD.idFiche = mods.idFiche
			@_fiche = null
		if mods.idUser?
			toBDD.idUser = mods.idUser
			@_user = null
		if mods.actif?
			if (mods.actif or (mods.actif is "1")) then toBDD.actif = "1"
			else toBDD.actif = "0"
		toBDD
	fiche: ->
		unless @_fiche? then @_fiche = Controller.uLog.fiches.get(@idFiche)
		@_fiche
	user: ->
		unless @_user? then @_user = Controller.uLog.users.get(@idUser)
		@_user
	moyenne: ->
		exercices = @fiche()?.exercices
		if exercices?
			totalCoeff = 0
			total = 0
			for exo in exercices.liste()
				total += exo.moyenne(@user(),@id)*exo.coeff
				totalCoeff += exo.coeff
			@_pasnote = (totalCoeff is 0)
			if totalCoeff is 0 then return NaN
			else return Math.round total/totalCoeff
		else return NaN
	update: ->
		@_moyenne = @moyenne() # et du coup @_fiche et @_user se mettent aussi à jour
		if @_moyenne<10 then @str_moyenne = "0"+@_moyenne
		else @str_moyenne = String @_moyenne
	match:(filter)-> not(filter.idUser? and (filter.idUser isnt @idUser)) and not(filter.idFiche? and (filter.idFiche isnt @idFiche))
