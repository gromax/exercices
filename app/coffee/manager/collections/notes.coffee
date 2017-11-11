class CNotes extends Collection
	url:"./api/notes"
	constructor: (liste) ->
		@model = MNote
		super(liste)
