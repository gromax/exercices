sortBy = (field, reverse, primer) ->
	key = (x) ->
		return if primer? then primer x[field] else x[field]
	return (a,b) ->
		A = key a
		B = key b
		if A<B then out = -reverse
		else
			if A>B then out = reverse
			else out = 0
		out

class SimpleCollection
	lastSort: null
	sortOrder: -1 # -1 pour reverse, +1 pour normal
	model: null
	constructor: (liste) ->
		if @model is null then @model = SimpleModel #Model par défaut
		@parse liste
		@events = []
	setCollection: (name,collection) -> @[name] = collection
	sortBy: (key, order) ->
		if key isnt @lastSort
			@sortOrder = -1
			@lastSort = key
		if order? then @sortOrder = order
		else @sortOrder = -@sortOrder
		@_liste.sort sortBy @lastSort, @sortOrder
		@
	push: (item,order=true) ->
		if item instanceof @model then new_item = item.setParent(@)
		else new_item = new @model(item,@)
		i=0
		found=false
		while (i<@_liste.length) and not found
			if @_liste[i].id is new_item.id
				# Un nouvel élément est considéré comme plus à jour
				# et il écrase l'existant
				@_liste[i] = new_item
				found=true
			else i++
		unless found then @_liste.push new_item
		if order and @lastSort? then @_liste.sort sortBy @lastSort, @sortOrder
		new_item
	remove: (item) ->
		i=0
		while i<@_liste.length
			if @_liste[i].id is item.id then @_liste.splice(i,1)
			else i++
		item
	get: (id, filter) ->
		id = Number id
		if (filter is null) or (typeof filter isnt "object")
			return (it for it in @_liste when it.id is id)[0]
		else
			return ( it for it in @_liste when (it.id is id) and (it.match?(filter)) )[0]
	parse: (liste) ->
		unless @_liste? then @_liste = []
		if liste? then @push(item,false) for item in liste
		if @lastSort? then @_liste.sort sortBy @lastSort, @sortOrder
	liste: (filter)->
		if filter?
			if (typeof filter.search is "string") and (filter.search isnt "") then filter.reg = new RegExp("("+filter.search+")")
			else filter.reg = null
			return @filteredList(filter)
		@_liste
	filteredList: (filter) ->
		output = []
		for item in @_liste
			if (item.match?(filter) isnt false) then output.push item
		output
	neighbours:(filter,needle)->
		# Si needle est un objet, on le chercher directement et on renvoie les objets précédents et suivants,
		# sinon on cherche l'objet dont l'id est needle et on renvoie les ids précédents et suivants
		out = { prev:null, next:null }
		liste = @liste(filter)
		if typeof needle is "object"
			indice = liste.indexOf(needle)
			if indice>0 then out.prev  = liste[indice-1]
			if indice<liste.length-1 then out.next = liste[indice+1]
		else
			indice = liste.map( (e) -> e.id ).indexOf(needle)
			if indice>0 then out.prev  = liste[indice-1].id
			if indice<liste.length-1 then out.next = liste[indice+1].id
		out
	remove: (filter) ->
		i=0
		if filter.id?
			while i<@_liste.length
				if @_liste[i].id is filter.id
					@_liste.splice(i,1)
					return
				else i++
		else
			while i<@_liste.length
				if @_liste[i].match(filter) then @_liste.splice(i,1)
				else i++

class CFichesUser extends SimpleCollection
	constructor: (liste) ->
		@model = MFiche
		super(liste)
	getExoFiche: (aEF) ->
		for fiche in @_liste
			if (out = fiche.exercices?.get(aEF))? then return out
		return null
class CExercices extends SimpleCollection
	constructor: ->
		@model = MExercice
		super Exercice.liste
	get: (id) -> return (it for it in @_liste when it.id is id)[0]
class Collection extends SimpleCollection
	_bddMessages:null
	fetch: -> $.get("./action.php?action=#{@name}List", null, @fetchCB, "json")
	fetchCB: (data) =>
		@setBddMessages data.messages
		unless data.error?
			@parse data
			@triggerEvent "fetch"
	add: (data,init=null) ->
		mod = new @model(init,@)
		mod.on {type:"change", cb:@addCB}
		mod.save data
	addCB: (item) =>
		@push item
		@triggerEvent "add", [item]
	setBddMessages: (messages) ->
		if messages? then @_bddMessages = messages
	bddMessages: ->
		if @_bddMessages? then @_bddMessages
		else []
	on: (ev) -> @events.push ev
	triggerEvent: (type, params=[@]) ->
		i=0
		while (i<@events.length)
			if @events[i].type is type
				if @events[i].obj? then @events[i].cb? @events[i].obj, params...
				else @events[i].cb? params...
				closeModal @events[i].modal
				if not(@events[i].forever) then @events.splice(i,1) # evenements once par défaut
			else i++
class CUsers extends Collection
	name: "users"
	constructor: (liste,@loggedUser) ->
		@model = MUser
		super(liste)
	get: (id) ->
		id = Number id
		if id is @loggedUser.id then return @loggedUser
		return (it for it in @_liste when it.id is id)[0]
	nextEleve: (id) ->
		index = (k for it,k in @_liste when it.id is id)[0]
		index++
		index++ while (index<@_liste.length) and not(@_liste[index]?.isEleve)
		if index<@_liste.length then return @_liste[index]
		else return null
	prevEleve: (id) ->
		index = (k for it,k in @_liste when it.id is id)[0]
		index--
		index-- while (index>=0) and not(@_liste[index]?.isEleve)
		if index>=0 then return @_liste[index]
		else return null
class CClasses extends Collection
	name: "classes"
	constructor: (liste) ->
		@model = MClasse
		super(liste)
class CFiches extends Collection
	name: "fiches"
	constructor: (liste) ->
		@model = MFiche
		super(liste)
	getExoFiche: (aEF) ->
		for fiche in @_liste
			if (out = fiche.exercices?.get(aEF))? then return out
		return null
class CExams extends Collection
	constructor: (liste, @parent) ->
		@model = MExam
		super(liste)
class CExosFiche extends Collection
	constructor: (liste, @exercices, @parent) -> # Les exercices étant fixes, ont fait une connexion directe
		@model = MExoFiche
		super(liste)
	@sortExosFiches: (liste, fiches) ->
		currentId = -1
		for item in liste
			if item.idFiche isnt currentId
				currentId = item.idFiche
				fiche = fiches.get currentId
			fiche?.pushExoFiche item
class CNotes extends Collection
	@fetchUFN:(liste)->
		$.get("./action.php?action=UFNlist", {liste:liste.join(";")}, @fetchUFN_CB, "json")
	constructor: (liste) ->
		@model = MNote
		super(liste)
class CAssoUF extends Collection
	name: "assoUF"
	constructor: (liste)->
		@model = MAssoUF
		super(liste)
	sortByUser: () ->
		if "userName" isnt @lastSort
			@sortOrder = 1
			@lastSort = "userName"
		else @sortOrder = -@sortOrder
		if @sortOrder is 1 then @_liste.sort (a,b) ->
			A = a.user().fullName()
			B = b.user().fullName()
			if A<B then -1
			else 1
		else @_liste.sort (a,b) ->
			A = a.user().fullName()
			B = b.user().fullName()
			if A<B then 1
			else -1
		@
