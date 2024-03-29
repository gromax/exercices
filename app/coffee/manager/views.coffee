
h_push = (arr,obj) ->
	arr.push(obj)
	return arr
# helper handlebar
#Handlebars.registerHelper 'selected', (index, value)->
#	if index is value then ' selected'
#	else ''

class View
	_defaultContainer: "#mainContent"
	config:null
	subViews:null
	constructor: (params) ->
		@divId = Controller.divIdCounter++
		@config = @mergeObjArr h_push(@init_config(params),params)
		@display()
	mergeObjArr: (arrayObjects) ->
		out = {}
		while obj = arrayObjects.shift()
			if (typeof obj is "object") and (obj isnt null)
				out[key] = val for key, val of obj
		out
	init_config:(params=null) -> [{ container:@_defaultContainer, divId:@divId, links:null }]
	events: -> []
	html: -> Handlebars.templates.erreur {}
	display: ->
		$container = $(@config.container)
		if @config.container is "#modalContent"
			$container.html Handlebars.templates.modal {
				title:@config.title
				otherButtons:@config.otherButtons
				html:@html()
				glyph:@_glyph
				idForm: if @formulaire? then @formulaire+@divId else null
				divId:@divId
				links:@config.links
			}
			$("#modalContainer").modal("show")
		else
			if @formulaire? then $container.html Handlebars.templates.default_form {
				title:@config.title
				otherButtons:@config.otherButtons
				html:@html()
				glyph:@_glyph
				idForm:@formulaire+@divId
				divId:@divId
				links:@config.links
			}
			else $container.html @html()
		@applyEvents()
		@final() # Traitement Mathjax et tooltip
	on: (eventsList) -> @events.push ev for ev in eventsList
	applyEvent: (eventObj,$container) ->
		# si selector commence par @ c'est qu'il s'agit d'un élément de l'objet
		# si selector commence par # alors c'est un id
		switch
			when eventObj.selector is null then selectorObj = $container
			when eventObj.selector.charAt(0) is "@"
				selectorObj = @[eventObj.selector.substring(1,eventObj.selector.length)]
			when eventObj.selector.charAt(0) is "#"
				selectorObj = $(eventObj.selector)
			else selectorObj = $(eventObj.selector,$container)
		if eventObj.subSelector? then selectorObj?.on eventObj.evt, eventObj.subSelector, @[eventObj.callback]
		else selectorObj?.on eventObj.evt, @[eventObj.callback]
	pushSubView: (sView) ->
		if @subViews is null then @subViews = [ sView ]
		else @subViews.push sView
		@
	applyEvents: ->
		$container = $(@config.container)
		$container.unbind()
		@bind_dom_and_events?($container)
		@applyEvent(ev,$container) for ev in @events()
		if @subViews isnt null
			v.applyEvents() for v in @subViews
	final: ->
		# éventuels traitements finaux comme le mathjax ou les toolstips
		$('[data-toggle="tooltip"]').tooltip()
		$('[data-toggle="popover"]').popover()
		MathJax.Hub.Queue(["Typeset",MathJax.Hub])
	formatValues: (arrValues)->
		out = {}
		out[it.name] = it.value for it in arrValues
		out
class VLogMenu extends View
	init_config:(params=null) -> h_push super(),{
		user:Controller.uLog
		showMessages:Controller.showMessages
		id:@divId
	}
	html: -> Handlebars.templates.navbarDte @config
	events: -> [
		{ evt:"click", selector:"#modifMyAccount#{@divId}", callback:"changeULog" }
		{ evt:"click", selector:"#toggleShowMessages#{@divId}", callback:"toggleShowMessages"}
	]
	changeULog: => new VUserMod { item:Controller.uLog }
	toggleShowMessages: =>
		@config.showMessages = Controller.showMessages = not Controller.showMessages
		@display()
class VList extends View
	_page: 1
	_pagination: 20
	_template: "Defaut_parent"
	_liste:null
	_actionList:null
	constructor: (params) ->
		@_actionList = {
			deleteButton:{ name:"delete", dom:["_id"] }
		}
		super(params)
	init_config:(params=null) -> h_push super(), {
			pagination:@_pagination
			template:@_template
			filtre:{}
		}
	push_action: (name,obj) ->
		# obj contient :
		# - les éléments du dom à récupérer
		# - le nom de la fonction de la vue que l'on doit utiliser
		@_actionList[name] = obj
		@
	html: ->
		liste = @collection().liste(@config.filtre)
		html = Handlebars.templates.buttonsBar {
			id:"buttons_#{@divId}"
			html_buttons:@config.html_buttons
			buttons:@config.buttons
			search:@config.search
			id_pagination:"pagination_#{@divId}"
			html_pagination:@pagination_html(liste)
		}
		html+= Handlebars.templates[@_template] {
			id:"liste_items_#{@divId}"
			params:@config
			liste_html:@items_html(liste)
		}
		if liste.length is 0
			html+= Handlebars.templates.listEmpty {
				id:"messageListeVide_#{@divId}"
				text:@textIfEmpty
			}
		html
	pagination_html: (liste)  ->
		n = liste.length
		items_par_page = if @config.pagination>0 then @config.pagination else n
		n_page = Math.ceil n/items_par_page
		if @_page-1>n_page then @_page = n_page
		if n_page>1 then pages = ( { index:i, active:i is @_page} for i in [1..n_page] )
		else pages = null
		Handlebars.templates.pagination { pages:pages, others:@config.othersNav }
	items_html: (liste) ->
		n = liste.length
		items_par_page = if @config.pagination>0 then @config.pagination else n
		indice_min = Math.min( n-1, Math.max(0,(@_page-1)*items_par_page) )
		indice_max = Math.min(n-1,@_page*items_par_page-1)
		(@itemAddLine item for item in liste[indice_min..indice_max]).join("")
	bind_dom_and_events: ($container)->
		# On attache l'objet aux éléments du dom qui recevront les événements
		$("#buttons_#{@divId}").data("view",@)
		$container.data("view",@)
	renderItems: ->
		liste = @collection().liste(@config.filtre)
		$("#pagination_#{@divId}").html @pagination_html(liste)
		$("#liste_items_#{@divId}").html @items_html(liste)
	events: ->
		[
			{ evt:"click", selector:null, subSelector:"a", callback:"action" },
			{ evt:"click", selector:null, subSelector:"button", callback:"buttonAction" },
			{ evt:"keyup", selector:"input[name='search']", callback:"searchAction" }
		]
	delete: (id) ->
		item = @collection().get id
		if confirm("Supprimer : #{item}")
			item.on { type:"delete", obj:@, cb:(view, item)->
				view.renderItems()
				view.final()
			}
			item.delete()
	action: (event) ->
		view = $(event.delegateTarget).data("view")
		dom = $(@)
		if view?
			switch
				when (link=dom.attr("link"))?
					window.location.href=link
				when dom.attr("sortBy")?
					# Tri dans les listes
					view.collection().sortBy dom.attr("sortBy")
					view._page = 1
					view.renderItems()
				when dom.attr("page")?
					view._page = Number $(@).attr("page")
					view.renderItems()
					view.final()
				when (action = view._actionList[dom.attr("name")])?
					view[action.name]?( (dom.attr(domItem) for domItem in action.dom)... )
	buttonAction: (event) ->
		view = $(event.delegateTarget).data("view")
		dom = $(@)
		if view? and (action = view._actionList[dom.attr("name")])?
			view[action.name]?( (dom.attr(domItem) for domItem in action.dom)... )
		event.stopPropagation()
	searchAction: (event) =>
		searchStr = $(event.currentTarget).val().toLowerCase()
		if searchStr.length<4 then @config.filtre.search = null
		else @config.filtre.search = searchStr
		@renderItems()
		@final()
	itemAddLine: (item) ->
		item.update?(@config) # Met à jour certains champs comme la moyenne pour une note ou le comptage d'items liés
		Handlebars.templates[@_itemTemplate] { id:"it#{item.id}_#{@divId}", item:item, params:@config, add:true }
	itemUpdateLine: (item,add) ->
		item.update?(@config) # Met à jour certains champs comme la moyenne pour une note ou le comptage d'items liés
		$("#it#{item.id}_#{@divId}").html(Handlebars.templates[@_itemTemplate]({ item:item, params:@config }))
class VUsersList extends VList
	_pagination:40
	_template: "User_parent"
	_itemTemplate: "User_item"
	_glyph: "glyphicon-user"
	init_config:(params=null)->
		@push_action "lockButton", { name:"lockAction", dom:["_id"] }
		@push_action "filtreClasseButton", { name:"filtrerClasse", dom:["_id"] }
		@push_action "forgottenButton", { name:"forgottenAction", dom:["_id"] }
		h_push super(), {
			showEmail:true
			showClasses:true
			showNote:true
			canModif:true
			showIds:Controller.uLog.isAdmin
			showPseudo:USE_PSEUDO and Controller.uLog.isAdmin
			showRanks:Controller.uLog.isAdmin
			filtre:@collection().permanentFilter
			buttons: if Controller.uLog.isAdmin then [{ link:"utilisateurs/add", title:"Ajouter un utilisateur"}] else null
		}
	collection: -> Controller.uLog.users
	lockAction: (idUser) ->
		item = @collection().get(Number idUser)
		item.on { type:"change", obj:@, cb:(view,item) ->
			view.itemUpdateLine item
			view.final()
		}
		item.save {locked:not item.locked}
	filtrerClasse: (idClasse) ->
		idClasse = Number idClasse
		if idClasse is @config.filtre?.idClasse
			@collection().setFilter null
			@config.filtre = null
		else
			filtre = { idClasse:idClasse, rank:"Élève", classe:Controller.uLog.classes.get(idClasse) }
			@collection().setFilter filtre
			@config.filtre = filtre
		@renderItems()
		@final()
	forgottenAction: (idUser) ->
		item = @collection().get(Number idUser)
		if item?
			item.on {
				type:"forgotten", cb:(data)->
					Controller.notyMessage "Un email a été envoyé.", "success"
			}
			item.forgottenPwd()
class VConsList extends VList
	_pagination:40
	_template: "Con_parent"
	_itemTemplate: "Con_item"
	_glyph: "glyphicon-off"
	init_config:(params=null) ->
		@push_action "_purge_button", { name:"purge", dom:[] }
		h_push super(), { buttons:[ { name:"_purge_button", title:"Purger cette liste"} ] }
	collection: -> Controller.uLog.cons
	purge: ->
		if confirm("Purger la liste ?")
			@collection().on { type:"purge", obj:@, cb:(view,col)->
				view.renderItems()
			}
			@collection().purge()
class VUserChoice extends VList
	_template: "User_parent"
	_itemTemplate: "User_item"
	_glyph: "glyphicon-user"
	init_config: (params=null) ->
		@push_action "userAddButton", { name:"userAdd", dom:["_id"] }
		@push_action "filtreClasseButton", { name:"filtreClasse", dom:["_id"] }
		h_push super(), {
			showClasses:true
			addButton:true
			filtre: { idClasse:Controller.filtreClasse?.id, rank:"Élève" }
			title: "Choix des utilisateurs"

		}
	userAdd: (idUser) ->
		user = @collection().get(Number idUser)
		fiche = @config.fiche
		Controller.uLog.UFlist.on {type:"add", obj:@, cb:(view,fiche)->
			view.renderItems()
		}
		Controller.uLog.UFlist.add { idUser:idUser, idFiche:fiche.id }
	collection: -> Controller.uLog.users
	filtreClasse: (idClasse) ->
		idClasse = Number idClasse
		if idClasse is @config.filtre.idClasse
			@config.filtre = null
			@collection().setFilter = null
		else
			@collection().setFilter { idClasse:idClasse, rank:"Élève", classe:Controller.uLog.classes.get(idClasse) }
			@config.filtre = { idClasse:idClasse, rank:"Élève", classe:Controller.uLog.classes.get(idClasse) }
		@renderItems()
		@final()
class VClassesList extends VList
	_template: "Classe_parent"
	_itemTemplate: "Classe_item"
	_glyph: "glyphicon-education"
	init_config:(params=null) ->
		# Config
		h_push super(), {
			showId:Controller.uLog.isAdmin
			showOwner:Controller.uLog.isAdmin
			showOpen:Controller.uLog.isAdmin or Controller.uLog.isProf
			showModify:Controller.uLog.isAdmin or Controller.uLog.isProf
			buttons:if Controller.uLog.isAdmin or Controller.uLog.isProf then [{ link:"classes/add", title:"Ajouter une classe"}] else null
		}
	collection: -> Controller.uLog.classes
class VFichesList extends VList
	_template: "Fiche_parent"
	_itemTemplate: "Fiche_item"
	_glyph: "glyphicon-file"
	init_config:(params=null) ->
		# Lancé seulement par prof et admin
		@push_action "activateButton", { name:"activateAction", dom:["_id"] }
		@push_action "visibleButton", { name:"visibleAction", dom:["_id"] }
		h_push super(), {
			showId:Controller.uLog.isAdmin
			showOwner:Controller.uLog.isAdmin
			showModify:true
			buttons:[{ link:"devoirs/add", title:"Ajouter une fiche"}]
		}
	collection: -> Controller.uLog.fiches
	activateAction: (id) ->
		item = @collection().get(Number id)
		item.on { type:"change", obj:@, cb:(view,item) ->
			view.itemUpdateLine item
			view.final()
		}
		item.save {actif:not item.actif}
	visibleAction: (id) ->
		item = @collection().get(Number id)
		item.on { type:"change", obj:@, cb:(view,item) ->
			view.itemUpdateLine item
			view.final()
		}
		item.save {visible:not item.visible}
class VExamsList extends VList
	_template: "Exam_parent"
	_itemTemplate: "Exam_item"
	_glyph: "glyphicon-blackboard"
	init_config:(params=null) ->
		# Lancé seulement par prof et admin
		@push_action "lockButton", { name:"lockAction", dom:["_id"] }
		@push_action "texButton", { name:"texAction", dom:["_id"] }
		@push_action "addExamButton", { name:"add", dom:[] }
		h_push super(), {
			showId:Controller.uLog.isAdmin
			showOwner:Controller.uLog.isAdmin
			showModify:true
			buttons:[{ name:"addExamButton", title:"Ajouter un exam"}]
		}
	collection: ->
		unless @_collection?
			if @config.fiche? then @_collection=@config.fiche.exams
		@_collection
	texAction: (id) ->
		exam = @collection().get(Number id)
		str = exam.toTex(false)
		str = str.replace(/&#x3D;/g, "=")
		str = str.replace(/&#x27;/g, "'")
		$("#zonetexte#{@divId}").val(str)
	lockAction: (id) ->
		item = @collection().get(Number id)
		item.on { type:"change", obj:@, cb:(view,item) ->
			view.itemUpdateLine item
			view.final()
		}
		item.save {locked:not item.locked}
	add: ->
		if @config.fiche?
			@collection().on { type:"add", obj:@, cb:(view, item)->
				view.renderItems()
				view.final()
			}
			@collection().add {
				idFiche:@config.fiche.id
				data:@config.fiche.toNewExam()
				nom:"#{ @config.fiche.nom } : #{currentDate(true)}"
			}
class VNotesList extends VList
	_template: "Note_parent"
	_itemTemplate: "Note_item"
	_glyph: "glyphicon-list-alt"
	_defaultLink: "erreur"
	init_config:(params=null) ->
		h_push super(), {
			showId:Controller.uLog.isAdmin
			showDel:Controller.uLog.isAdmin or Controller.uLog.isProf
		}
	collection: -> @config.user.notes()
class VList_aUF extends VList
	_template: "aUF_parent"
	_itemTemplate: "aUF_item"
	_glyph: "glyphicon-file"
	textIfEmpty: "Aucun devoir dans la liste."
	init_config:(params=null) ->
		@push_action "_sort_notes_by_name", { name:"sortNotesByName", dom:[] }
		@push_action "activateButton", { name:"activateAction", dom:["_id"] }
		othersNav = null
		buttons = null
		if params.user? and (Controller.uLog.isProf or Controller.uLog.isAdmin)
			# Création des boutons de navigation d'un utilisateur à l'autre
			# Sans doute moins utile à l'avenir
			user = params.user
			neighbours = user.parent.neighbours(null,user)
			if neighbours.prev is null then precNav = { name:"Précédent", class:"disabled", link:""}
			else precNav = { name:"Élève précédent", class:"", link:"#notes-eleve:"+neighbours.prev.id }
			if neighbours.next is null then suivNav = { name:"Suivant", class:"disabled", link:""}
			else suivNav = { name:"Élève suivant", class:"", link:"#notes-eleve:"+neighbours.next.id }
			othersNav=[precNav, suivNav]
		if params.fiche? and (Controller.uLog.isProf or Controller.uLog.isAdmin)
			# On propose d'ajouter des élèves
			buttons=[ { link:"notes-devoir:#{params.fiche.id}/ajout-eleve", title:"Ajouter des élèves"}, { name:"_sort_notes_by_name", title:"Trier par nom"}]
		h_push super(), {
			othersNav:othersNav
			buttons:buttons
		}
	collection: -> Controller.uLog.UFlist
	sortNotesByName: () ->
		@collection().sortByUser?()
		@_page = 1
		@renderItems()
	activateAction: (id) ->
		item = @collection().get id
		item.on { type:"change", obj:@, cb:(view,item) ->
			view.itemUpdateLine item
			view.final()
		}
		item.save {actif:not item.actif}
class VList_aEF extends VList
	_template: "aEF_parent"
	_itemTemplate: "aEF_item"
	_glyph: "glyphicon-edit"
	_collection:null
	init_config:(params=null) ->
		# En présence de aUF, on s'intéresse aux notes. Sinon on s'intéresse à l'objet fiche
		if params.aUF? then complement = { user:params.user, aUF:params.aUF }
		else complement = {
			buttons:[
				{ link:"devoir:#{params.fiche.id}/add", title:"Ajouter un exercice"}
				{ link:"#{params.links?.notes}#{params.fiche.id}", title:"Voir les élèves"}
			]
			actif:params.fiche.actif
			visible:params.fiche.visible
			idFiche:params.fiche.id
		}
		# Calcul du titre
		###
		@title = "Liste des exercices du devoir : "+params.fiche?.nom
		if not params.fiche?.actif then @title += " (Vérouillé)"
		if params.user? then @title+= " ["+params.user.prenom+" "+params.user.nom+"]"
		###
		# Sortie config
		h_push super(), complement
	collection: -> @_collection ? (@_collection=@config.fiche?.exercices)
class VExercicesList extends VList
	_itemTemplate: "Exercice_item"
	_glyph: "glyphicon-edit"
	init_config:(params=null) ->
		if params.fiche? then link = "devoir:#{params.fiche.id}/add:"
		else link = "tester-exercice:"
		h_push super(), {
			search:true
			showKeyWords:Controller.uLog.isAdmin
			link:link
		}
	collection: -> Controller.uLog.exercices
class VMod extends View
	formulaire:"form"
	init_config: (params=null) -> h_push super(), { idForm:@formulaire+@divId }
	html:-> Handlebars.templates[@_template]({ item: @config.item, params:@config })
	bind_dom_and_events: ($container)->
		$("#form#{@divId}").data("view",@).validate {
			ignore:[],
			rules: @_rules,
			submitHandler: (event) ->
				$form = $(@currentForm)
				view = $form.data("view")
				if view?
					values = view.formatValues $form.serializeArray()
					if view.config.item?
						view.config.item.save values
						if view.config.links?.cancel? then view.config.item.on { type:"change", url:"#"+view.config.links.cancel }
					else
						view.collection().add values
						if view.config.links?.cancel? then view.collection().on { type:"add", url:"#"+view.config.links.cancel }
				false
		}
class VUserMod extends VMod
	_template:"modUser"
	_rules: {
		"pseudo":{
			"required": true,
			"minlength": PSEUDO_MIN_SIZE,
			"maxlength": PSEUDO_MAX_SIZE
		},
		"email": {
			"required": not USE_PSEUDO
			"email": true
		},
		"pwd": {
			"required": true
		},
		"nom":{
			"required": true
		},
		"pwdConfirm" : {
			"required" : true,
			"equalTo" : "#pwdInput"
		}
	}
	events: -> [ { evt:"click", selector:"button[name='changePWD']", callback:"togglePWD" } ]
	init_config: (params=null) ->
		mdp = (params.mdp is true) # indique que l'on demande un changement de mdp
		if params.item?
			if Controller.uLog.isAdmin then comp = {
				title:"Modification de <b>#{params.item.fullName(true)}</b>"
				changePseudo:USE_PSEUDO and not params.item.isRoot
				changeInfos:not (mdp or params.item.isRoot)
				changePwd:mdp or params.item.isRoot
				chooseRank:false
			}
			else comp = { # Les choix ci-dessous envoient directement le formulaire de mot de passe pour un élève verrouillé
				title:"Modification de <b>#{params.item.fullName(true)}</b>"
				changePseudo:false
				changeInfos:not (mdp or (params.item.locked and not Controller.uLog.isProf))
				changePwd:mdp or (params.item.locked and not Controller.uLog.isProf )
				chooseRank:false
			}
		else comp = {
			title:"Création d'un utilisateur"
			changePseudo:USE_PSEUDO
			changeInfos:true
			changePwd:true
			chooseRank:Controller.uLog.isRoot
			defaultRank:"Prof"
		}
		h_push super(), comp
	collection: -> Controller.uLog.users
	togglePWD: ()=>
		$("div[name='pwdZone']",@container).html(Handlebars.templates.modUserPwd({}))
class VClasseMod extends VMod
	_template:"modClasse"
	_rules: {
		"nom":{
			"required": true,
			"minlength": NOMCLASSE_MIN_SIZE,
			"maxlength": NOMCLASSE_MAX_SIZE
		},
		"pwd": {
			"required": true
		}
	}
	init_config: (params=null) -> h_push super(), {
			title: if params.item? then "Modification de <b>#{params.item.nom}</b>" else "Création d'une classe"
		}
	collection: -> Controller.uLog.classes
class VFicheMod extends VMod
	_template:"modFiche"
	_rules: {
		"nom":{
			"required": true,
		}
	}
	init_config: (params=null) -> h_push super(), {
			title: if params.item? then "Modification d'un devoir" else "Création d'un devoir"
		}
	collection: -> Controller.uLog.fiches
class VExamMod extends VMod
	_template:"modExam"
	_rules: {
		"nom":{
			"required": true,
		}
	}
	init_config: (params=null) -> h_push super(), {
			title: "Modification d'un devoir"
		}
	collection: -> Controller.uLog.exams
class VExoFicheMod extends VMod
	_template:"modFicheExo"
	_rules: {
		"num":{
			"required": true,
			"number": true
		},
		"coeff":{
			"required": true,
			"number": true
		}
	}
	init_config:(params=null) ->
		@fiche = params.fiche
		if typeof params.item is "number"
			idE=params.item
			delete params.item
			exoModel = Controller.uLog.exercices.get(idE)
			comp = {
				title:"Ajout d'un exercice dans le devoir"
				exoModel:exoModel
				nouveau:true
				num:1
				coeff:1
				options:Exercice.read_options(null,exoModel.options)
			}
		else
			exoModel = Controller.uLog.exercices.get(params.item.idE)
			comp = {
				title:"Modification d'un exercice dans le devoir"
				exoModel:exoModel
				nouveau:false
				num:params.item.num
				coeff:params.item.coeff
				options:Exercice.read_options(params.item.options,exoModel.options)
			}
		h_push super(), comp
	formatValues:(arrValues) ->
		# Collecte les champs et mets à part ce qui correspond aux options
		liste = @config.exoModel.options
		unless liste? then return super(arrValues)
		out = { options:{} }
		for it in arrValues
			if liste[it.name]? then out.options[it.name]=it.value
			else out[it.name] = it.value
		out
	collection: -> @fiche.exercices
class VClassesJoin extends View
	# Rejoindre une classe, créant un compte élève
	html: ->  Handlebars.templates.classesJoin { classes:Controller.uLog.classes.liste() }
class VInscription extends View
	init_config:(params=null) ->
		h_push super(), {
			title:"Inscription dans la classe <b>#{params.classe.nom}</b>"
		}
	html:->
		if @config.authorized # phase finale de l'inscription
			Handlebars.templates.inscription {
				nomClasse:@config.classe.nom
				pwdClasse:$("input[name='pwdClasse']").val()
				idForm:"inscription#{@divId}"
			}
		else
			Handlebars.templates.inscription {
				nomClasse:@config.classe.nom
				idForm:"inscription#{@divId}"
				pwd:true
			}
	bind_dom_and_events:($container) ->
		classe = @config.classe
		if @config.authorized
			$("#inscription#{@divId}").data("classe",classe).validate {
				rules: {
					"email": {
						"required": true
						"email": true
					},
					"pwd": {
						"required": true
					},
					"nom":{
						"required": true
					},
					"pwdConfirm" : {
						"required" : true,
						"equalTo" : "#pwdInput"
					}
				},
				submitHandler: () ->
					$(@currentForm).data("classe").join {
						nom:$("input[name='nom']").val()
						prenom:$("input[name='prenom']").val()
						email:$("input[name='email']").val()
						pwdClasse: $("input[name='pwdClasse']").val()
						pwd:$("input[name='pwd']").val()
					}
					false
			}
			classe.on { type:"inscription", cb: (classe, data) ->
				Controller.uLog.log data.user, data
				pushUrlInHistory "#nouvelinscrit"
				Controller.load "#nouvelinscrit"
			}
		else
			# Première phase: on vérifie le mdp pour entrer dans la classe
			$("#inscription#{@divId}").data("classe",classe).validate {
				rules: {
					"pwdClasse": {
						"required": true
					}
				},
				submitHandler: () ->
					$(@currentForm).data("classe").testMDP $("input[name='pwdClasse']").val()
					false
			}
			classe.on({ type:"testMDP", obj:@, cb:@inscriptionFinal })
	inscriptionFinal: (view,classe) ->
		view.config.authorized = true
		view.display()
class VExercice extends View
	exo:null
	init_config: (params)->
		switch
			when params.oNote? # Exercice commencé ou terminé
				oEF = params.oNote.exoFiche()
				aUF = params.oNote.aUF
				@exo = new Exercice {
					oEF:oEF
					aUF:aUF
					divId:@divId
				}
				@exo.init { note:params.oNote }
				comp = {
					title:@exo.title
					showNote:true
					showReload:false
					todo:oEF.num # Nombre de répatitions demandées
					done:params.oNote.parent.filteredList({aEF:params.oNote.aEF, aUF:aUF}).length
					neighbours: params.oNote.parent?.neighbours({aEF:params.oNote.aEF},params.oNote.id) # Permet la navigation entre les notes
					upBDDbutton:Controller.uLog.isAdmin or Controller.uLog.isProf
					showDebug:if Controller.uLog.isAdmin then "debug#{@divId}" else false
				}
			when params.oEF?
				@exo = new Exercice { # Nouvel exercice noté - aUF et oEF fournis
					oEF:params.oEF
					aUF:params.aUF
					divId:@divId
				}
				@exo.init null
				comp = {
					title:@exo.title
					showNote:true
					showReload:true
				}
			when params.examInfos?
				@exo = new Exercice { # exercice dans un examen
					idE:params.examInfos.idE
					options:params.examInfos.options
					divId:@divId
				}
				@exo.init params.examInfos
				comp = {
					title:@exo.title
					showNote:true
					showReload:params.canModif
					examInfos : params.examInfos
					linkNext: params.linkNext
					linkPrev: params.linkPrev
				}
			else
				@exo = new Exercice { # Simple test
					idE:params.idE
					divId:@divId
				}
				@exo.init null
				comp = { # Simple test
					title:@exo.title
					showNote:false
					showReload:true
					showOptions:if @exo.model.options? then "config#{@divId}" else false
				}
		h_push super(), comp
	html:->
		html_showOptions = if @config.showOptions?
			conf = Handlebars.templates.exoOptionsDiv {
				id:@config.showOptions
				idForm:"form_opt_#{@divId}"
				options:@exo.data.options
			}
		else
			""
		html_showDebug = if @config.showDebug?
			conf = Handlebars.templates.exoDebugDiv {
				id:@config.showDebug
				idForm:"form_debug_#{@divId}"
				inputs:JSON.stringify @exo.data.inputs
				answers:@exo.data.answers
			}
		else
			""
		Handlebars.templates.exoHeader(@config)+html_showOptions+html_showDebug+@exo.makeContainers()+"<div id='note_#{@divId}'></div>"
	bind_dom_and_events:($container)->
		$("#upBDD_#{@divId}").on 'click', (event) =>
			@exo.updateBDD()
			Controller.notyMessage("Mise à jour éffectuée","success")
			false
		$("#again_#{@divId}").on 'click', (event) =>
			@exo.init null
			if (infos = @config.examInfos)? then infos.update @exo.data.inputs
			@display()
			false
		$("#form_opt_#{@divId}").on 'submit', (event) =>
			@exo.reloadOptions $(event.delegateTarget).serializeArray()
			@config.title = @exo.title
			@display()
			false
		if @config.showDebug then $("#form_debug_#{@divId}").data("view",@).validate {
			ignore:[],
			submitHandler: (event) ->
				$form = $(@currentForm)
				view = $form.data("view")
				if view?
					values = view.formatValues $form.serializeArray()
					inputs = values.inputs
					delete values.inputs
					exo = view.exo
					note = exo.note()
					if inputs? then note.inputs = JSON.parse inputs
					note.answers = values
					exo.init { note:note }
					view.display()
				false
		}
		# initialisation des Brique graphique
		stg.display?() for stg in @exo.stages
		@exo.run()
class VHome extends View
	# Accueil. L'éventuel paramètre indique s'il faut afficher la fenêtre de nouvel inscrit.
	init_config:(params=null) ->
		if Controller.uLog.isEleve then @pushSubView(new VList_aUF {
			container:"#mesdevoirs#{@divId}"
			links:{direct:"devoir:", indirect:null}
			filtre:{idUser:Controller.uLog.id}
			user:Controller.uLog
		})
		h_push super(), { reinit:params?.reinit is true }
	html:->
		if Controller.uLog.isEleve
			Handlebars.templates.home {
				user:Controller.uLog
				reinit:@config.reinit
				fiches:Controller.uLog.fiches.liste()
				unfinished:Controller.uLog.notes().liste({ finished:false }).length>0
				html_devoirs:"<div id='mesDevoirs#{@divId}'>#{@subViews[0].html()}</div>"
				html_premiere_connexion: if @config.nouveau then Handlebars.templates.premiereConnexion { classe:Controller.uLog.classe() } else null
			}
		else Handlebars.templates.home { user:Controller.uLog, reinit:@config.reinit }
class VConnexion extends View
	formulaire:"connexion"
	init_config:(params=null)->
		if params.reconnexion is true
			h_push super(), {
				title:"Reconnexion"
				reconnexion:false
				otherButtons:null
				identifiant:Controller.uLog.identifiant()
				links:{ cancel:"deconnexion" }
			}
		else
			h_push super(), {
				title:"Connexion"
				reconnexion:false
				otherButtons:[{id:"forgottenButton#{@divId}", text:"Mot de passe oublié"}]
			}
	html:-> Handlebars.templates.connexion @config
	bind_dom_and_events:($container) ->
		if @config.reconnexion
			$("##{@formulaire}#{@divId}").validate {
				rules: {"identifiant":{"required": true}, "pwd":{"required":true}},
				submitHandler: () =>
					if $("input[name='identifiant']").val() isnt Controller.uLog.identifiant()
						$("#messages#{@divId}").html Handlebars.templates.alertMessage { message:"Vous devez vous reconnecter avec le même <b>email</b> !" }
					else
						Controller.uLog.connexion $("input[name='identifiant']").val(), $("input[name='pwd']").val()
					false
			}
			Controller.uLog.on { type:"connexion" }
		else
			$("##{@formulaire}#{@divId}").validate {
				rules: { "identifiant":{"required": true}, "pwd":{"required":true} },
				submitHandler: () ->
					pwd = $("input[name='pwd']").val()
					if pwd is "" then Controller.notyMessage("BUG : Vous avez beau taper un mot de passe, il n'est pas envoyé... Essayez de réactualiser la page (touche F5 sur PC)","alert")
					else Controller.uLog.connexion $("input[name='identifiant']").val(), $("input[name='pwd']").val()
					false
			}
			$("#forgottenButton#{@divId}").on 'click', (event) =>
				identifiant = $("input[name='identifiant']").val()
				emailRegEx = /// ^[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9._-]{2,}\.[a-z]{2,4}$ ///i
				if identifiant.match emailRegEx
					Controller.uLog.on { type:"forgotten", cb:(data)=>
						if data.found then message = "Un email vous a été envoyé."
						else message = "Aucun utilisateur n'a cet email."
						$("#messages#{@divId}").html Handlebars.templates.alertMessage { message:message }
					}
					Controller.uLog.forgottenPwd identifiant
				else
					$("#messages#{@divId}").html Handlebars.templates.alertMessage { message:"Indiquez un <b>email valide</b> !" }
			Controller.uLog.on { type:"connexion" }
		$("input[name='identifiant']").focus()
