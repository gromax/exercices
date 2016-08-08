
class @Tools
	@clone: (obj) ->
		output = {}
		if typeof obj isnt "object" then return output
		output[key] = val for key, val of obj
		output
	@merge: (objectA, objectB) ->
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
		objectA
	@mergeMulti:(arrayObjects) ->
		out = {}
		while obj = arrayObjects.shift()
			if (typeof obj is "object") and (obj isnt null)
				out[key] = val for key, val of obj
		out
	@isRealApproxIn:(goods,answer,marge) ->
		# goods est un tableau de nombres
		# ans est un nombre ou un objet
		if typeof answer is "string" then answer = NumberManager.makeNumber(answer)
		if (answer instanceof NumberObject)
			if not(answer instanceof RealNumber) then return false
			answer = answer.toNumber()
		if typeof answer isnt "number" then return false
		for g in goods
			if Math.abs(g-answer)<=marge then return g
		false
	@aleaEntreBornes: (a,b) -> Math.floor((Math.random() * (b+1-a)) + a)
	@typeIsArray: ( value ) ->
		value and
			typeof value is 'object' and
			value instanceof Array and
			typeof value.length is 'number' and
			typeof value.splice is 'function' and
			not ( value.propertyIsEnumerable 'length' )
	@isInteger: (number) ->
		if (typeof number is "number") and (number is Math.round(number)) then return true
		false
	@arrayShuffle: (arr) ->
		i = arr.length
		if i is 0 then return arr
		while i--
			j = Math.floor(Math.random() * i)
			temp = arr[i]
			arr[i] = arr[j]
			arr[j] = temp
		arr
	@parseFloat: (str) ->
		if typeof str is "undefined" then return 0
		if typeof str is "number" then return str
		if typeof str isnt "string" then return NaN
		str = "0"+str.commaToPoint()
		return parseFloat(str)
	@notyMessage: (text, type="error") ->
		# Type possibles : alert (bleu) ou warning, info, success, error
		noty({
			layout: 'topLeft',
			theme: 'bootstrapTheme',
			type: type,
			text: text,
			timeout: 2,
			maxVisible:10,
			animation: {
				open: 'animated bounceInUp', # jQuery animate function property object
				close: 'animated bounceOutLeft', # jQuery animate function property object
				easing: 'swing', # easing
				speed: 500 # opening & closing animation speed
			}
		})
