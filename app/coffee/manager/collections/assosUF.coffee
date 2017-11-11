class CAssoUF extends Collection
	name: "assoUF"
	url:"./api/assosUF"
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
