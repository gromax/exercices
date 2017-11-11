class SimpleModel
	# Sans gestion de BDD
	# defaultValues() optionel
	# match?() optionel
	constructor: (json, @parent) ->
		@set @defaultValues()
		@set json
		if json? then @parse?() # Si json = null, rien à parser
	defaultValues: -> {}
	set: (json) ->
		@[key] = value for key, value of json
		@
	setParent: (parent) ->
		@parent = parent
		@
	equals: (other) -> (other?.id is @id)
