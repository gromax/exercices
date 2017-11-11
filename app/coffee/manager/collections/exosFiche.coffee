class CExosFiche extends Collection
	url:"./api/exosfiche"
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
