# Un bon bout du parsing peut être automatique
# le jsonToBDD doit être automatique aussi
# pseudo ne sert à rien => changer pour email

#	console.log "caller is " + arguments.callee.caller.toString()

class SimpleModel
	# Sans gestion de BDD
	# defaultValues() optionel
	# match?() optionel
	constructor: (json, @parent) ->
		@set @defaultValues()
		@set json
		@parse?()
	defaultValues: -> {}
	set: (json) ->
		@[key] = value for key, value of json
		@
	setParent: (parent) ->
		@parent = parent
		@
	equals: (other) -> (other?.id is @id)
	currentDate: ->
		date = new Date()
		day = String date.getDate()
		if day.length is 1 then day = "0"+day
		month = String(date.getMonth()+1)
		if month.length is 1 then month = "0"+month
		"#{date.getFullYear()}-#{month}-#{day}"

class MExercice extends SimpleModel
	_glyph: "glyphicon-edi"
	tex_exists:false
	defaultValues: -> { title:"", description:"", keyWords:null }
	parse: ->
		if @keyWords isnt null then @searchValue = (@title+";"+@description+";"+@keyWords.join(";")).toLowerCase()
		else @searchValue = (@title+";"+@description).toLowerCase()
		if @tex? then @tex_exists = true
	match: (filter) -> filter.reg?.test(@searchValue) isnt false
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
			$.post("./action.php?action=#{@_name}Save", @pending_save, @saveCB, "json")
	saveCB: (data) =>
		if data.error
			if data.unlogged
				Controller.uLog.on {
					type:"connexion"
					cb:()=>$.post("./action.php?action=#{@_name}Save", @pending_save, @saveCB, "json")
				}
				new VConnexion { reconnexion:true }
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
	delete: ->
		$.post("./action.php?action=#{@_name}Delete", { id:@id }, @deleteCB, "json")
	deleteCB: (data) =>
		if data.error
			Controller.errorMessagesList data.messages, @enteteForMessages(), @_glyph
		else
			@parent.remove @
			@postDelete?() #Éventuels traitement suivant une suppression
			@triggerEvent "delete"
			if @showSuccessMessages then Controller.notyMessage @enteteForMessages()+"Succès de la suppression.", "success", @_glyph
class MUser extends Model
	_glyph: "glyphicon-user"
	_name: "user"
	_notes:null
	_infosLoaded:false # garantit qu'on a bien toutes les infos pour cet utilisateur
	enteteForMessages: -> "<b>#{@} :</b> "
	defaultValues: -> { pseudo:"", nom: "", prenom:"", email:"", rank:"Off", locked:false }
	toString: -> "@#{@id} :[#{@nom} #{@prenom}]"
	fullName: (reverse=false) -> if reverse then @prenom+" "+@nom else @nom+" "+@prenom
	identifiant:-> if @isRoot then "root" else @email
	parse: ->
		if @id? then @id = Number @id
		if @idClasse? then @idClasse = Number @idClasse
		unless @nomClasse? then @nomClasse = @rank
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
		if mods.pwd? then toBDD.pwd = MD5(PRE_SALT+mods.pwd+POST_SALT)
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
		else $.post("./action.php?action=getUserNotes", { id: @id }, @fetchFullInfos_CB, "json")
	fetchFullInfos_CB: (data) =>
		if data.error then Controller.errorMessagesList data.messages, "<b>Chargement des infos de #{@prenom} #{@nom} :</b> ", @_glyph
		else
			@fetchProcessing data
			@triggerEvent "infos-fetched"
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
class MLog extends MUser
	initialized: false
	classes:null
	users:null
	fiches:null
	exercices:null
	_infosLoaded:true # Aucune importance pour un prof ou +. Un élève charge toutes ses données au démarrage
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
	connexion: (identifiant,pwd) ->
		if SEND_CRYPTED_PWD then $.post("./action.php?action=connexion", {identifiant:identifiant, pwd:MD5(PRE_SALT+pwd+POST_SALT), dataFetch: identifiant isnt @identifiant()}, @connexionCB, "json")
		else $.post("./action.php?action=connexion", {identifiant:identifiant, pwd:pwd, dataFetch: identifiant isnt @identifiant()}, @connexionCB, "json")
	connexionCB: (data) =>
		if data.success
			@log data.logged, data
			@triggerEvent "connexion"
		else
			Controller.errorMessagesList data.messages, "<b>Connexion :</b>", "glyphicon-log-in"
	init: (local)->
		if local then @initCB { uLog:{ nom:"Disconnected", prenom:"", email:"", rank:"Off", date:"",locked:false},users:[],classes:[],fiches:[],messages:[] }
		else $.post("./action.php?action=getData", {}, @initCB, "json")
	initCB: (data) =>
		if data.uLog?
			@log data.uLog,data
			@triggerEvent "init"
	deconnexion: (eventObject=null) ->
		if eventObject isnt null
			eventObject.type = "deconnexion"
			@on eventObject
		$.post("./action.php?action=deconnexion", @deconnexionCB, "json")
	deconnexionCB: (data) =>
		if data.logged?.rank is "Off"
			@delog data
			@triggerEvent "deconnexion"
		else Controller.notyMessage "Échec de la déconnexion !", "error"
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
	forgotten: (identifiant) ->
		# On demande à réinitialiser le mot de passe d'un élève
		$.post("./action.php?action=forgotten", {identifiant:identifiant}, @forgottenCB, "json")
	forgottenCB: (data) =>
		if data.error
			Controller.errorMessagesList data.messages, "Mot de passe oublié : ", @_glyph
		else
			@triggerEvent "forgotten",[data]
	reinitMDP: (key) ->
		if @isOff then $.post("./action.php?action=reinitMDP", {key:key}, @reinitMDP_CB, "json")
	reinitMDP_CB: (data) =>
		if data.error
			Controller.errorMessagesList data.messages, "Réinitialisation de mot de passe : ", @_glyph
		else
			if data.success
				@log data.logged, data
				@triggerEvent "reinitMDP",[@,true]
			else @triggerEvent "reinitMDP",[@,false]
class MClasse extends Model
	_glyph: "glyphicon-education"
	_name: "classe"
	enteteForMessages: -> "<b>#{@nom} :</b> "
	defaultValues: -> { nom:"", ouverte:false, description:"", idOwner:null, pwd:"", date:today() }
	toString: -> "["+@id+"]"+@nom
	parse: ->
		if @id? then @id = Number @id
		@ouverte = (@ouverte is "1") or (@ouverte is true)
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
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
		$.post("./action.php?action=testMDP", { pwd:pwd, id:@id}, @testMDP_CB, "json")
	testMDP_CB: (data) =>
		if data.error then Controller.errorMessagesList data.messages, "Inscription dans <b>#{@nom}</b> : ", @_glyph
		else @triggerEvent "testMDP"
	join: (userData) ->
		userData.idClasse= @id
		$.post("./action.php?action=join", userData, @joinCB, "json")
	joinCB: (data) =>
		if data.error then Controller.errorMessagesList data.messages, "<b>Inscription dans #{@nom} :</b> ", @_glyph
		else @triggerEvent "inscription", [@, data]
class MFiche extends Model
	_glyph: "glyphicon-file"
	_name: "fiche"
	exercices: null # Liste des exercices dans la fiche
	_fetched:false # Toutes les informations ne sont pas chargées
	enteteForMessages: -> "<b>#{@nom} :</b> "
	defaultValues: -> { nom:"", description:"", idOwner: null, date:today(), visible:false, actif:false, ownerName:Controller.uLog.nom }
	toString: -> "["+@id+"]"+@nom
	parse: ->
		if @id? then @id = Number @id
		if @idOwner? then @idOwner = Number @idOwner
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
		@visible = (@visible is "1") or (@visible is true)
		@actif = (@actif is "1") or (@actif is true)
		if Controller.uLog.isEleve then @_fetched = true
		@
	bddJSON: (mods) ->
		toBDD = {}
		if @id? then toBDD.id = @id
		if mods.nom? then toBDD.nom = mods.nom
		if mods.description? then toBDD.description = mods.description
		if mods.visible?
			if (mods.visible or (mods.visible is "1")) then toBDD.visible = "1"
			else toBDD.visible = "0"
		if mods.actif?
			if (mods.actif or (mods.actif is "1")) then toBDD.actif = "1"
			else toBDD.actif = "0"
		toBDD
	load: (eventObject) ->
		eventObject.type = "load"
		@on eventObject
		@getFullInfos()
	getFullInfos: ->
		# Récupère les exercices associés à la fiche
		if not @_fetched # avec un élève tout est chargé au début
			$.post("./action.php?action=getFullFicheInfos", { id: @id }, @getFullInfosCB, "json")
		else @triggerEvent "load"
	getFullInfosCB: (data)=>
		if data.error then Controller.errorMessagesList data.messages, "<b>Chargement de #{@nom} :</b> ", @_glyph
		else
			item.idFiche = @id for item in data.eleves
			Controller.uLog.UFlist.parse data.eleves
			@_fetched = true
			@exercices = new CExosFiche data.exercices, Controller.uLog.exercices, @
			# Chargement des notes
			if data.faits?
				current_idUser=null
				for item in data.faits
					idUser = Number item.idUser
					if current_idUser isnt idUser
						user=Controller.uLog.users.get(idUser)
						current_idUser = idUser
					user?.pushNote(item)
			if data.exams? then @exams = new CExams data.exams, @
			@triggerEvent "load"
	pushExoFiche: (exofiche) ->
		unless @exercices? then @exercices = new CExosFiche null,@parent.exercices,@
		@exercices.push exofiche
	toNewExam: ->
		# Produit un tableau de data pour l'instance d'un nouvel exam
		( exo.toNewExam() for exo in @exercices.liste() )
	moyenne: (user) ->
		if @exercices?
			totalCoeff = 0
			total = 0
			for exo in @exercices.liste()
				total += exo.moyenne(user)*exo.coeff
				totalCoeff += exo.coeff
			@_pasnote = (totalCoeff is 0)
			if totalCoeff is 0 then return NaN
			else return Math.round total/totalCoeff
		else return NaN
	update: (config)->
		@_moyenne = @moyenne config?.user
	match: (filter) -> (not filter.doneBy?) #or (@_eleves? and @hasToBeDoneBy(filter.doneBy))
	postDelete: -> Controller.uLog.UFlist.remove({idFiche:@id})
class MExam extends Model
	_glyph: "glyphicon-blackboard"
	_name: "exam"
	_nExos: null
	enteteForMessages: -> "<b>Examen @#{@id} :</b> "
	defaultValues: -> { nom:"Nouvel exam" }
	parse: ->
		if @id? then @id = Number @id
		if @idFiche? then @idFiche = Number @idFiche
		else @idFiche = @parent?.parent?.id
		if typeof @data is "string" then @data = JSON.parse @data
		if @date? then @dateFr = @date.replace /(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"
		else @date = @currentDate()
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
class MCon extends Model
	_glyph: "glyphicon-off"
	_name: "con"
	parse: ->
		if @id? then @id = Number @id
		if @date?
			jour = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$3/$2/$1"
			heure = @date.replace /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/, "$4:$5:$6"
			@dateFr = "#{jour} #{heure}"
		else @date = @currentDate()
		@success = (@success is "1") or (@success is true)
		if @identifiant?
			@user = Controller.uLog.users.getByField("email",@identifiant)
		@
	bddJSON: (mods) -> {}
	enteteForMessages: -> "<b>Connexion @#{@id} :</b> "
	defaultValues: -> {  }
class MExoFiche extends Model
	_glyph: "glyphicon-edit"
	_name: "exofiche"
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
		exo = new Exercice { model:@exercice }
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
class MNote extends Model
	_name: "note"
	_exofiche: null # mémorisation de l'objet exofiche lié
	showSuccessMessages: false
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
class MAssoUF extends Model
	_name: "assoUF"
	showSuccessMessages: false
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
