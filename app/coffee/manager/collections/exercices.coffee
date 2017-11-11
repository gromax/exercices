class CExercices extends SimpleCollection
	constructor: ->
		@model = MExercice
		super Exercice.liste
	get: (id) -> return (it for it in @_liste when it.id is id)[0]
