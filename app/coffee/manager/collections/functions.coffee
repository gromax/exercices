sortBy = (field, reverse, primer) ->
	key = (x) ->
		return if primer? then primer x[field] else x[field]
	return (a,b) ->
		A = key a
		B = key b
		if A<B then out = -reverse
		else
			if A>B then out = reverse
			else out = 0
		out
