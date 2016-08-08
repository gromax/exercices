
grecques = ["alpha", "beta", "delta", "psi", "pi", "theta", "phi", "xi", "rho", "epsilon", "omega", "nu", "mu", "gamma", "Alpha", "Beta", "Delta", "Psi", "Pi", "Theta", "Phi", "Xi", "Rho", "Epsilon", "Omega", "Nu", "Mu", "Gamma"]

String::pointToComma = -> @replace '.', ","
String::commaToPoint = -> @replace ',', "."
String::toFloat = -> parseFloat("0"+@commaToPoint())
String::numberFormat = -> @toFloat().toStr()
String::parse = (params) -> Parser.parse String(@), params
Number::toStr = (decimals) ->
	if typeof decimals is "undefined" then output = String(@)
	else output = @toFixed(decimals)
	return output.pointToComma()
Number::toResolution = (resolution) -> Math.round(@/resolution)*resolution
Number::round = (decimals) -> Number(@.toFixed(decimals))
Number::isInteger = -> @ is Math.round(@)
Number::toNumberObject = -> new RealNumber(@)

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
typeIsArray = ( value ) ->
	value and
		typeof value is 'object' and
		value instanceof Array and
		typeof value.length is 'number' and
		typeof value.splice is 'function' and
		not ( value.propertyIsEnumerable 'length' )
arrayIntersect= (a, b) ->
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
extractSquarePart= (value) ->
	if value instanceof NumberObject then value = value.toNumber()
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
