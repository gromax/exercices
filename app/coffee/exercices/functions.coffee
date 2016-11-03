
isInteger = (number) ->
	if (typeof number is "number") and (number is Math.round(number)) then return true
	false
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
arrayShuffle = (arr) ->
	i = arr.length
	if i is 0 then return arr
	while i--
		j = Math.floor(Math.random() * i)
		temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp
	arr
isRealApproxIn = (goods,answer,marge) ->
	# goods est un tableau de nombres
	# ans est un nombre ou un objet
	if (answer = mM.test.isFloat(answer)) is false then return false
	for g in goods
		if Math.abs(g-answer)<=marge then return g
	false
pointToComma = (str) -> str.replace '.', ","
commaToPoint = (str) -> str.replace ',', "."
numToStr = (num,decimals) ->
	if decimals? then out = num.toFixed decimals
	else out = String num
	out.replace '.', ","
quantifyNumber = (num,quantum) -> Math.round(num/quantum)*quantum
fixNumber = (num,decimals) -> Number(num.toFixed(decimals))

colors = (id) ->
	switch id
		when 0 then { tex:"red", html:"#ff0000" }
		when 1 then { tex:"JungleGreen", html:"#347c2c" }
		when 2 then { tex:"Violet", html:"#8d38c9" }
		when 3 then { tex:"Orange", html:"#ffa500" }
		when 4 then { tex:"blue", html:"#0000ff" }
		when 5 then { tex:"gray", html:"#808080" }
		when 6 then { tex:"Thistle", html:"#d2b9d3" }
		when 7 then { tex:"Mahogany", html:"#c04000" }
		when 8 then { tex:"yellow", html:"#ffff00" }
		when 9 then { tex:"CornflowerBlue", html:"#6495ed" }
		else { tex:"black", html:"#000000" }

h_ineqSymb = ["<", ">", "\\leqslant", "\\geqslant"]
h_genId = () -> Math.floor(Math.random() * 10000)
h_init = (inpName,saveObj,_min,_max, force=false) ->
	# prend inp s'il est défini, sinon un entier alea entre _min et _max
	if (not force) and (saveObj[inpName])? then saveObj[inpName] = Number saveObj[inpName]
	else saveObj[inpName] = mM.alea.real { min:_min, max:_max }
h_random_order = (n,def) ->
	# Donne un tableau [1..n] mais ordonné au hasard
	# Si def est donné, sous forme de texte, on prend default
	if def?
		# default doit être un string
		(Number c for c in def)
	else
		arrayShuffle([0..n-1])
h_clone = (obj) ->
	if (typeof obj isnt "object") or (obj is null) then return obj
	out = {}
	out[key] = h_clone(obj[key]) for key of obj
	out

# helper handlebar
#Handlebars.registerHelper 'colorListItem', (color)->
#	switch color
#		when "error" then "list-group-item-danger"
#		when "good" then "list-group-item-success"
#		when "info" then "list-group-item-info"
#		else ""

