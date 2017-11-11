class CUsers extends Collection
	name: "users"
	url:"./api/users"
	constructor: (liste,@loggedUser) ->
		@model = MUser
		super(liste)
	get: (id) ->
		id = Number id
		if id is @loggedUser.id then return @loggedUser
		return (it for it in @_liste when it.id is id)[0]
	nextEleve: (id, idClasse) ->
		index = (k for it,k in @_liste when it.id is id)[0]
		index++
		if idClasse?
			index++ while (index<@_liste.length) and not(@_liste[index]?.isEleve) and (@_liste[index]?.idClasse isnt idClasse)
		else
			index++ while (index<@_liste.length) and not(@_liste[index]?.isEleve)
		if index<@_liste.length then return @_liste[index]
		else return null
	prevEleve: (id,idClasse) ->
		index = (k for it,k in @_liste when it.id is id)[0]
		index--
		if idClasse?
			index-- while (index>=0) and not(@_liste[index]?.isEleve) and (@_liste[index]?.idClasse isnt idClasse)
		else
			index-- while (index>=0) and not(@_liste[index]?.isEleve)
		if index>=0 then return @_liste[index]
		else return null
