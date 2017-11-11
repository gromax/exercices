class MLog extends MUser
	initialized: false
	classes:null
	users:null
	fiches:null
	exercices:null
	lastTime:null
	_infosLoaded:true # Aucune importance pour un prof ou +. Un élève charge toutes ses données au démarrage
	urlRoot: "./api/session"
	@_glyph: "glyphicon-log-in"
	setLocal:(local)-> @local = (local is true)
	reset: (data) ->
		@classes = new CClasses data?.classes
		@UFlist = new CAssoUF null
		@users = new CUsers data?.users, @
		@users.on { type:"setFilter", forever:true, obj:Controller.menuLog, cb:(menu,col)->
			menu.display()
		}
		@parent = @users # permet d'assurer une compatibilité avec un user normal
		if @exercices is null then @exercices = new CExercices()
		@fiches = new CFiches data?.fiches
		# Lien entre collections
		@users.setCollection "classes", @classes
		@users.setCollection "fiches", @fiches
		@fiches.setCollection "users", @users
		@fiches.setCollection "exercices", @exercices
		# Dans le cas d'un élève, le chargement des notes et des fiches se fait au chargement
		if @isEleve then @fetchProcessing data
	timeOut:->
		if (@lastTime is null) or (@isOff)
			@lastTime = (new Date()).getTime()
		else
			currentTime = (new Date()).getTime()
			delta = currentTime - @lastTime
			if delta>60000
				$.ajax({
					dataType:"json"
					method:"GET"
					url:@urlRoot+"/test"
				}).always(@updateLoggedTime)
				@lastTime = currentTime
	updateLoggedTime: (data) =>
		if data.logged then @lastTime = (new Date()).getTime()
		else new VConnexion { reconnexion:true }
	connexion: (identifiant,pwd) ->
		$.ajax({
			data:JSON.stringify {
				identifiant:identifiant
				pwd:pwd
				dataFetch: identifiant isnt @identifiant()
			}
			dataType:"json"
			method:"POST"
			url:@urlRoot
		}).done(@connexionSuccessCB).fail(@connexionErrorCB)
	connexionSuccessCB: (data) =>
		@log data.uLog, data
		@triggerEvent "connexion"
	connexionErrorCB: (data) =>
		Controller.errorMessagesList data.messages, "<b>Connexion :</b>", "glyphicon-log-in"
	init: (local)->
		if local then @initCB { uLog:{ nom:"Disconnected", prenom:"", email:"", rank:"Off", date:"",locked:false},users:[],classes:[],fiches:[],messages:[] }
		else
			$.ajax({
				dataType:"json"
				method:"GET"
				url:@urlRoot
			}).always(@initCB)
	initCB: (data) =>
		if data.uLog?
			@log data.uLog,data
			@triggerEvent "init"
	deconnexion: (eventObject=null) ->
		if eventObject isnt null
			eventObject.type = "deconnexion"
			@on eventObject
		$.ajax({
			dataType:"json"
			method:"DELETE"
			url:@urlRoot+"/"+@id
		}).done(@deconnexionSuccessCB).fail(@deconnexionErrorCB)
	deconnexionSuccessCB: (data) =>
		@delog data
		@triggerEvent "deconnexion"
	deconnexionErrorCB: (data) =>
		Controller.notyMessage "Échec de la déconnexion !", "error"
	log: (log,data) ->
		if (Number(log.id) isnt @id) or not @initialized
			@initialized = true
			@set log
			@parse()
			@reset data
			@triggerEvent "change"
	delog: (data) ->
		if not @isOff
			@id = null
			@set @defaultValues()
			@parse()
			@reset data
			@triggerEvent "change"
	forgottenPwd: ( identifiant ) ->
		$.ajax({
			data: { identifiant:identifiant }
			dataType:"json"
			method:"POST"
			url:@urlRoot+"/initpwd"
		}).done(@forgottenPwdSucessCB).fail(@forgottenPwdErrorCB)
	forgottenPwdSucessCB: (data) =>
		@triggerEvent "forgotten",[data]
	forgottenPwdErrorCB: (data) =>
		Controller.errorMessagesList data.messages, "Mot de passe oublié : ", @_glyph
	reinitMDP: (key) ->
		if @isOff
			$.ajax({
				data:{ key:key }
				dataType:"json"
				method:"POST"
				url:@urlRoot+"/keylog"
			}).done(@reinitMDPSuccessCB).fail(@reinitMDPErrorCB)
	reinitMDPSuccessCB: (data) =>
		@log data.logged, data
		@triggerEvent "reinitMDP",[@,true]
	reinitMDPErrorCB: (data) =>
		if data.status is 401
			@triggerEvent "reinitMDP",[@,false]
		else
			Controller.errorMessagesList data.messages, "Réinitialisation de mot de passe : ", @_glyph

