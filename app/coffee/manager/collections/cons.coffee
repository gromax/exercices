class CCons extends Collection
	name:"cons"
	url:"./api/cons"
	constructor: (liste)->
		@model = MCon
		super(liste)
	purge: ->
		$.ajax({
			dataType:"json"
			method:"DELETE"
			url:@url
		}).done(@purgeSuccessCB).fail(@fetchErrorCB)
	purgeSuccessCB: (data)=>
		@_liste = []
		@triggerEvent "purge"
	purgeErrorCB: (data) =>
		switch data.status
			when 401
				# connexion requise
				Controller.uLog.on {
					type:"connexion"
				}
				new VConnexion { reconnexion:true, container:"modalContent" }
			when 403
				alert("Vous n'êtes pas autorisé à effectuer cette action.");
			when 404
				alert("Vous essayer de modifier un item qui n'existe pas dans la base de données.");
			when 422
				alert("Données invalides.");
			else
				alert("Erreur inconnue.")
