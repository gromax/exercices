class SimpleCollection
	lastSort: null
	sortOrder: -1 # -1 pour reverse, +1 pour normal
	model: null
	permanentFilter:null
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
	getByField: (field, value) ->
		for it in @_liste
			if it[field] is value then return it
		return null
	parse: (liste) ->
		unless @_liste? then @_liste = []
		if liste? then @push(item,false) for item in liste
		if @lastSort? then @_liste.sort sortBy @lastSort, @sortOrder
	liste: (inFilter)->
		if (filter = inFilter ? @permanentFilter)?
			if (typeof filter.search is "string") and (filter.search isnt "") then filter.reg = new RegExp("("+filter.search+")")
			else filter.reg = null
			return @filteredList(filter)
		@_liste
	setFilter: (inFilter) ->
		@permanentFilter = inFilter
		@triggerEvent "setFilter"
		@
	filteredList: (filter) ->
		output = []
		for item in @_liste
			if (item.match?(filter) isnt false) then output.push item
		output
	neighbours:(filter,needle)->
		# Si needle est un objet, on le chercher directement et on renvoie les objets précédents et suivants,
		# sinon on cherche l'objet dont l'id est needle et on renvoie les ids précédents et suivants
		out = { prev:null, next:null }
		liste = @liste(filter ? @permanentFilter)
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
