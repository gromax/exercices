class CFiches extends Collection
	name: "fiches"
	url:"./api/fiches"
	constructor: (liste) ->
		@model = MFiche
		super(liste)
	getExoFiche: (aEF) ->
		for fiche in @_liste
			if (out = fiche.exercices?.get(aEF))? then return out
		return null
