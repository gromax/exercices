class CClasses extends Collection
	name: "classes"
	url:"./api/users"
	constructor: (liste) ->
		@model = MClasse
		super(liste)
