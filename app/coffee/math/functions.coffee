
grecques = ["alpha", "beta", "delta", "psi", "pi", "theta", "phi", "xi", "rho", "epsilon", "omega", "nu", "mu", "gamma", "Alpha", "Beta", "Delta", "Psi", "Pi", "Theta", "Phi", "Xi", "Rho", "Epsilon", "Omega", "Nu", "Mu", "Gamma"]
DECIMAL_SEPARATOR = ','
DECIMAL_MAX_PRECISION = 10
SOLVE_MAX_PRECISION = 14
ERROR_MIN = 0.00000000000001



isInteger = (number) ->
	if (typeof number is "number") and (number is Math.round(number)) then return true
	false
isInfty = (number) ->
	if (typeof number is "number") and ((number is Number.POSITIVE_INFINITY) or (number is Number.NEGATIVE_INFINITY)) then return true
	false
signatures_comparaison= (a,b,order=1) ->
	a_s = a.signature()
	b_s = b.signature()
	if a_s is "1" then return -order
	if b_s is "N/A" then return -order
	if b_s is "1" then return order
	if a_s is "N/A" then return order
	if a_s >= b_s then return order
	-order
in_array = (_item, _array) ->
	for item in _array
		return true if item == _item
	false
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
arrayIntersect = (a, b) ->
	# les tableaux doivent être triés
	ai=0
	bi=0
	result = []
	while (ai < a.length) and (bi < b.length)
		if a[ai]<b[bi] then ai++
		else if a[ai]>b[bi] then bi++
		else
			result.push(a[ai])
			ai++
			bi++
	result
extractSquarePart = (value) ->
	if value instanceof NumberObject then value = value.floatify().float()
	if not isInteger(value) then return 1
	if value is 0 then return 0
	value = Math.abs(value)
	extract = 1
	while value % 4 is 0
		extract*=2
		value /= 4
	i=3
	j=9
	while j<=value
		while value % j is 0
			value /= j
			extract *= i
		j += 4*i+4
		i += 2
	extract
