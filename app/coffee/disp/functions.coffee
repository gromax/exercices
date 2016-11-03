
isArray = ( value ) ->
	value and
		typeof value is 'object' and
		value instanceof Array and
		typeof value.length is 'number' and
		typeof value.splice is 'function' and
		not ( value.propertyIsEnumerable 'length' )
mergeObj = (objectA, objectB) ->
	# cas où on transmet un tableau en argument 1
	if isArray(objectA)
		out = {}
		while obj = objectA.shift()
			if (typeof obj is "object") and (obj isnt null)
				out[key] = val for key, val of obj
		return out
	else
		# objectB overrides objectA
		if (typeof objectA isnt "object") or (objectB is null) then objectA = {}
		if (typeof objectB isnt "object") or (objectB is null) then return objectA
		objectA[key] = val for key, val of objectB
		if arguments.length>2
			i=2
			while i<arguments.length
				o = arguments[i]
				if (typeof o is "object") and (o isnt null)
					objectA[key] = val for key, val of o
				i++
		return objectA
