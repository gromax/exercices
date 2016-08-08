
class GestClavier
	# Cette classe gère les boutons pour caractères spéciaux
	constructor: ->
		@start = 0
		@end = 0
		@lastInput = null
		@bindInput(arguments...)
	bindInput: ->
		for jquery_node in arguments
			if @lastInput is null then @lastInput = jquery_node
			jquery_node.focusout(
				(event) => @follow($(event.currentTarget))
			)
	follow: (jquery_node) ->
		@start = jquery_node.getSelectionStart()
		@end = jquery_node.getSelectionEnd()
		@lastInput = jquery_node
	clavier: (pre_car,post_car,efface) ->
		# Détecte la position de début et de fin de la sélection
		# écrit pre_car avant, post_car après, et efface indique si on laisse la sélection
		if @lastInput isnt null
			text = @lastInput.val()
			if efface
				selection = ""
				delta = @start - @end + pre_car.length + post_car.length
			else
				selection = text.substring(@start, @end)
				delta = pre_car.length + post_car.length
			newText = text.substring(0,@start)+pre_car+selection+post_car+text.substring(@end)
			@lastInput.val(newText)
			@lastInput.setCursorPosition(@end+delta)
