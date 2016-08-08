
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
		@config = Tools.mergeMulti h_push(@init_config(params),params)
		@display()
	init_config:(params=null) -> [{ container:@_defaultContainer, divId:@divId }]
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
			}
			$("#modalContainer").modal("show")
		else
			if @formulaire? then $container.html Handlebars.templates.default_form { idForm:@formulaire+@divId, html:@html(), title:@config.title }
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
		MathJax.Hub.Queue(["Typeset",MathJax.Hub])
class VLogMenu extends View
	init_config:(params=null) -> h_push super(),{ user:Controller.uLog, showMessages:Controller.showMessages, id:@divId }
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
	init_config:(params=null) -> h_push super(), {
			pagination:@_pagination
			template:@_template
			filtre:{}
		}
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
	add: ->
		@collection().on {type:"add", obj:@, cb:(view, item)->
			view.renderItems()
			view.final()
		}
		@modal()
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
				when dom.attr("name") is "filtreClasseButton"
					# Pour listUser
					id = Number dom.attr("_id")
					nomClasse = dom.attr("nomClasse")
					if id>0
						if id is view.config.filtre.idClasse
							view.config.filtre.idClasse = null
							Controller.uLog.setClasseFiltre null
						else
							view.config.filtre.idClasse = id
							Controller.uLog.setClasseFiltre Controller.uLog.classes.get(id)
						view.renderItems()
						view.final()
				when dom.attr("idExoChoice")?
					# Pour le mod de choix d'exercice
					# L'objet VExercicesList a été attaché à un config.exChoice = VList_EF. Son modal gère la création d'une exercice.
					view.config.exoChoice?.modal(Number dom.attr("idExoChoice"))
		#event.stopPropagation() -> Pose aussi problème dans le modal lors du choix d'exercice...
	buttonAction: (event) ->
		view = $(event.delegateTarget).data("view")
		dom = $(@)
		if view?
			name = dom.attr("name")
			switch name
				when "_add_button" then view.add()
				when "_sort_notes_by_name"
					# Tri par nom, dans une liste de notes Vlist_aUF
					view.collection().sortByUser?()
					view._page = 1
					view.renderItems()
				when "_eleves_button"
					new VUserChoice { fiche:view.config.fiche, viewToRefresh:view }
				when "deleteButton"
					item = view.collection().get dom.attr("_id")
					if confirm("Supprimer : #{item}")
						item.on { type:"delete", obj:view, cb:(view,item)->
							view.renderItems()
							view.final()
						}
						item.delete()
				when "activateButton"
					# Pour VFichesList
					item = view.collection().get dom.attr("_id")
					item.on { type:"change", obj:view, cb:(view,item) ->
						view.itemUpdateLine item
						view.final()
					}
					item.save {actif:not item.actif}
				when "visibleButton"
					# Pour VFichesList
					item = view.collection().get dom.attr("_id")
					item.on { type:"change", obj:view, cb:(view,item) ->
						view.itemUpdateLine item
						view.final()
					}
					item.save {visible:not item.visible}
				when "editButton"
					item = view.collection().get dom.attr("_id")
					item.on { type:"change", obj:view, cb:(view,item) ->
						view.itemUpdateLine item
						view.final()
					}
					view.modal item
				when "lockButton"
					# Pour VUserList
					item = view.collection().get dom.attr("_id")
					item.on { type:"change", obj:view, cb:(view,item) ->
						view.itemUpdateLine item
						view.final()
					}
					item.save {locked:not item.locked}
				when "userAddButton"
					# Pour VUserChoice => Ajout d'une asso user-fiche
					idUser = Number dom.attr("_id")
					user = view.collection().get idUser
					fiche = view.config.fiche
					Controller.uLog.UFlist.on {type:"add", obj:view, cb:(view,fiche)->
						view.renderItems()
						view.config.viewToRefresh?.renderItems() # Raffraichit la vue des UF qui est en fond
					}
					Controller.uLog.UFlist.add { idUser:idUser, idFiche:fiche.id }
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
		h_push super(), {
			showEmail:true
			showClasses:true
			showNote:true
			canModif:true
			showIds:Controller.uLog.isAdmin
			showPseudo:USE_PSEUDO and Controller.uLog.isAdmin
			showRanks:Controller.uLog.isAdmin
			filtre:{ idClasse:Controller.uLog.classeFiltre?.id }
			buttons: if Controller.uLog.isAdmin then [{ name:"_add_button", title:"Ajouter un utilisateur"}] else null
		}
	collection: -> Controller.uLog.users
	modal: (item) -> new VUserMod { item:item }
class VUserChoice extends VList
	_defaultContainer: "#modalContent"
	_template: "User_parent"
	_itemTemplate: "User_item"
	_glyph: "glyphicon-user"
	init_config: (params=null) ->
		h_push super(), {
			showClasses:true
			addButton:true
			filtre: { idClasse:Controller.uLog.classeFiltre?.id, rank:"Élève" }
			title: "Choix des utilisateurs"
		}
	collection: -> Controller.uLog.users
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
			buttons:if Controller.uLog.isAdmin or Controller.uLog.isProf then [{ name:"_add_button", title:"Ajouter une classe"}] else null
		}
	collection: -> Controller.uLog.classes
	modal: (item) -> new VClasseMod { item:item }
class VFichesList extends VList
	_template: "Fiche_parent"
	_itemTemplate: "Fiche_item"
	_glyph: "glyphicon-file"
	init_config:(params=null) ->
		# Lancé seulement par prof et admin
		h_push super(), {
			showId:Controller.uLog.isAdmin
			showOwner:Controller.uLog.isAdmin
			showModify:true
			buttons:[{ name:"_add_button", title:"Ajouter une fiche"}]
		}
	collection: -> Controller.uLog.fiches
	modal: (item) -> new VFicheMod { item:item }
class VNotesList extends VList
	_template: "Note_parent"
	_itemTemplate: "Note_item"
	_glyph: "glyphicon-list-alt"
	_defaultLink: "erreur"
	init_config:(params=null) ->
		# Calcul du titre
		###
		switch
			when params.exoFiche? then @title = "Liste des notes du devoir : #{params.exoFiche.parent.parent.nom}/#{params.exoFiche.exercice.title}"
			when Controller.uLog.id is params.user.id
				if params.unfinished then @title = "Liste de vos exercices inachevés"
				else @title = "Liste de vos notes"
			else
				if params.unfinished then @title = "Liste de vos exercices inachevés de #{params.user.prenom} #{params.user.nom}"
				else @title = "Liste des notes de #{params.user.prenom} #{params.user.nom}"
		###
		# Config
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
		othersNav = null
		buttons = null
		if params.user? and (Controller.uLog.isProf or Controller.uLog.isAdmin)
			# Création des boutons de navigation d'un utilisateur à l'autre
			# Sans doute moins utile à l'avenir
			user = params.user
			precedent = user.parent.prevEleve user.id
			if precedent is null then precNav = { name:"Précédent", class:"disabled", link:""}
			else precNav = { name:"Élève précédent", class:"", link:"#notes-eleve:"+precedent.id }
			suivant = user.parent.nextEleve user.id
			if suivant is null then suivNav = { name:"Suivant", class:"disabled", link:""}
			else suivNav = { name:"Élève suivant", class:"", link:"#notes-eleve:"+suivant.id }
			othersNav=[precNav, suivNav]
		if params.fiche? and (Controller.uLog.isProf or Controller.uLog.isAdmin)
			# On propose d'ajouter des élèves
			buttons=[ { name:"_eleves_button", title:"Ajouter des élèves"}, { name:"_sort_notes_by_name", title:"Trier par nom"}]
		h_push super(), {
			othersNav:othersNav
			buttons:buttons
		}
	collection: -> Controller.uLog.UFlist
class VList_aEF extends VList
	_template: "aEF_parent"
	_itemTemplate: "aEF_item"
	_glyph: "glyphicon-edit"
	_collection:null
	init_config:(params=null) ->
		# En présence de aUF, on s'intéresse aux notes. Sinon on s'intéresse à l'objet fiche
		if params.aUF? then complement = { user:params.user, aUF:params.aUF }
		else complement = { buttons:[ { name:"_add_button", title:"Ajouter un exercice"}, { link:"#{params.links?.notes}#{params.fiche.id}", title:"Voir les élèves"}], actif:params.fiche.actif, visible:params.fiche.visible }
		# Calcul du titre
		###
		@title = "Liste des exercices du devoir : "+params.fiche?.nom
		if not params.fiche?.actif then @title += " (Vérouillé)"
		if params.user? then @title+= " ["+params.user.prenom+" "+params.user.nom+"]"
		###
		# Sortie config
		h_push super(), complement
	collection: ->
		unless @_collection?
			if @config.oUF? then @_collection = @config.oUF.fiche()?.exercices
			else if @config.fiche? then @_collection=@config.fiche?.exercices
		@_collection
	modal: (item) ->
		if item? then new VExoFicheMod { item:item, fiche:@config.fiche ? @config.oUF.fiche() }
		else new VExercicesList { container:"#modalContent", exoChoice:@ }
class VExercicesList extends VList
	_itemTemplate: "Exercice_item"
	_glyph: "glyphicon-edit"
	init_config:(params=null) ->
		h_push super(), {
			search:true
			showKeyWords:Controller.uLog.isAdmin
			exoChoice:if params.exoChoice? then true else false
		}
	collection: -> Controller.uLog.exercices
class VMod extends View
	_defaultContainer: "#modalContent"
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
					if view.config.item? then view.config.item.save values
					else view.collection().add values
				false
		}
		if @config.container is @_defaultContainer
			if @config.item? then @config.item.on {type:"change", modal:true}
			else @collection().on {type:"add", modal:true}
	formatValues: (arrValues)->
		out = {}
		out[it.name] = it.value for it in arrValues
		out
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
	events: -> [ { evt:"click", selector:"div[name='classesList']", subSelector:"a", callback:"action" } ]
	action: (event) ->
		classe = Controller.uLog.classes.get $(@).attr("classeId")
		if classe? then new VInscription { classe:classe }
class VInscription extends View
	_defaultContainer: "#modalContent"
	init_config:(params=null) ->
		h_push super(), {
			title:"Inscription dans la classe <b>#{params.classe.nom }}</b>"
		}
	html:->
		if @config.authorized # phase finale de l'inscription
			Handlebars.templates.inscription {
				classe:@config.classe
				pwdClasse:$("input[name='pwd']").val()
				id:"inscription_#{@divId}"
			}
		else
			Handlebars.templates.inscription {
				classe:@config.classe
				pwd:true
				id:"inscription_#{@divId}"
			}
	bind_dom_and_events:($container) ->
		classe = @config.classe
		if @config.authorized
			$("#inscription_#{@divId}").data("classe",classe).validate {
				rules: {
					"pseudo":{
						"required": true,
						"minlength": PSEUDO_MIN_SIZE,
						"maxlength": PSEUDO_MAX_SIZE
					},
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
					$("#inscrForm").data("classe").join {
						#pseudo:$("input[name='pseudo']").val()
						nom:$("input[name='nom']").val()
						prenom:$("input[name='prenom']").val()
						email:$("input[name='email']").val()
						pwdClasse: $("input[name='pwdClasse']").val()
						pwd:MD5(PRE_SALT+$("input[name='pwd']").val()+POST_SALT)
					}
					false
			}
			classe.on { type:"inscription", modal:true, cb: (classe, data) ->
				Controller.uLog.log data.user, data
				pushUrlInHistory "#nouvelinscrit"
				Controller.load "#nouvelinscrit"
			}
		else
			# Première phase: on vérifie le mdp pour entrer dans la classe
			$("#inscription_#{@divId}").data("classe",classe).validate {
				rules: {
					"pwd": {
						"required": true
					}
				},
				submitHandler: () ->
					$("#inscriptionForm").data("classe").testMDP $("input[name='pwd']").val()
					false
			}
			classe.on({ type:"testMDP", cb:@inscriptionFinal })
	inscriptionFinal: (classe) ->
		@config.authorized = true
		@display()
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
				@exo.init params.oNote
				comp = {
					title:@exo.model.title
					showNote:true
					showReload:false
					todo:oEF.num # Nombre de répatitions demandées
					done:params.oNote.parent.filteredList({aEF:params.oNote.aEF, aUF:aUF}).length
					neighbours: params.oNote.parent?.neighbours({aEF:params.oNote.aEF},params.oNote.id) # Permet la navigation entre les notes
					upBDDbutton:Controller.uLog.isAdmin or Controller.uLog.isProf
				}
			when params.oEF?
				@exo = new Exercice { # Nouvel exercice noté - aUF et oEF fournis
					oEF:params.oEF
					aUF:params.aUF
					divId:@divId
				}
				@exo.init null
				comp = {
					title:@exo.model.title
					showNote:true
					showReload:true
				}
			else
				@exo = new Exercice { # Simple test
					idE:params.idE
					divId:@divId
				}
				@exo.init null
				comp = { # Simple test
					title:@exo.model.title
					showNote:false
					showReload:true
					showOptions:if @exo.model.options? then "config#{@divId}" else false
				}
		h_push super(), comp
	html:->
		if @config.showOptions? then conf = Handlebars.templates.exoOptionsDiv {
			id:@config.showOptions
			idForm:"form_opt_#{@divId}"
			options:@exo.data.options
		}
		else conf = ""
		Handlebars.templates.exoHeader(@config)+conf+@exo.makeContainers()+"<div id='note_#{@divId}'></div>"
	bind_dom_and_events:($container)->
		$("#upBDD_#{@divId}").on 'click', (event) =>
			@exo.updateBDD(true)
			Controller.notyMessage("Mise à jour éffectuée","success")
			false
		$("#again_#{@divId}").on 'click', (event) =>
			@exo.init null
			@display()
			false
		$("#form_opt_#{@divId}").on 'submit', (event) =>
			@exo.reloadOptions $(event.delegateTarget).serializeArray()
			@display()
			false
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
		super()
	html:->
		if Controller.uLog.isEleve
			Handlebars.templates.home {
				user:Controller.uLog
				fiches:Controller.uLog.fiches.liste()
				unfinished:Controller.uLog.notes().liste({ finished:false }).length>0
				html_devoirs:"<div id='mesDevoirs#{@divId}'>#{@subViews[0].html()}</div>"
				html_premiere_connexion: if @config.nouveau then Handlebars.templates.premiereConnexion { classe:Controller.uLog.classe() } else null
			}
		else Handlebars.templates.home {user:Controller.uLog}
class VConnexion extends View
	_defaultContainer: "#modalContent"
	formulaire:"connexion"
	init_config:(params=null)->
		h_push super(), {
			title:"Connexion"
			otherButtons:[{id:"forgottenButton#{@divId}", text:"Mot de passe oublié"}]
		}
	html:-> Handlebars.templates.connexion @config
	bind_dom_and_events:($container) ->
		$("##{@formulaire}#{@divId}").validate {
			rules: {"identifiant":{"required": true}},
			submitHandler: () ->
				Controller.uLog.connexion $("input[name='identifiant']").val(), $("input[name='pwd']").val()
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
				Controller.uLog.forgotten identifiant
			else
				$("#messages#{@divId}").html Handlebars.templates.alertMessage { message:"Indiquez un <b>email valide</b> dans le champ identifiant !" }
		Controller.uLog.on { type:"connexion", modal:true }
		$("input[name='pwd']").val("")
		$("input[name='identifiant']").focus()
