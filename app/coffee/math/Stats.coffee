
class @Stats
	constructor: (values,effectifs) ->
		if not Tools.typeIsArray(effectifs) then effectifs = []
		ne = effectifs.length
		switch
			when typeof values is "string" then @makeFromString(values)
			when not Tools.typeIsArray(values) or (values.length is 0)
				@serie = null
				@serieBrute = []
				return
			when ne is 0
				# Aucun effecif n'es donné
				# La présence d'un couple value|effectif suffit à créer une table triée
				n = values.length
				brut = true
				i=0
				while (i<n) and brut
					if typeof values[i] is "object" then brut = false
					else i++
				if brut
					@serie = null
					@serieBrute = values
				else
					@serie = []
					@serieBrute = null
					for item in values
						if typeof item is "object" then @serie.push item
						else @serie.push { value:item, effectif:1 }
			else
				@serieBrute = null
				@serie = []
				for value,i in values
					if (i<ne) then @serie.push { value:value, effectif:effectifs[i] }
					else @serie.push { value:value, effectif:1 }
	refresh: ->
		@_N = null
		@_S = null
		@_S2 = null
		@_alreadySorted = false
		@_alreadyCounted = false
	makeFromString: (data) ->
		#L'info est stokée dans une chaine. Les caleurs sont séparées par ;
		#La présence d'un | indique un couple valeur|effectif
		table = data.split(";")
		serie = []
		brut = true
		for item in table
			item_arr = item.split("|")
			if item_arr.length is 2
				brut = false
				effectif = Number(item_arr[1])
				value = Number(item_arr[0])
				serie.push { value:value, effectif:effectif }
			else serie.push Number(item_arr[0])
		if brut
			@serie = serie
			@serieBrute = null
		else
			@serie = []
			for item in serie
				if typeof item is "object" then @serie.push item
				else @serie.push { value:item, effectif:1 }
			@serieBrute = null
	sort: ->
		if @_alreadySorted? then return @
		@_alreadySorted = true
		if @serie?
			@serie.sort (a,b) ->
				if a.value>=b.value then return 1
				else -1
		else
			@serieBrute.sort (a,b) ->
				if a>=b then return 1
				else -1
		@
	N: ->
		if @_N? then return @_N
		if @serieBrute? then @_N = @serieBrute.length
		else
			@_N=0
			@_N += item.effectif for item in @serie
		@_N
	sum: ->
		if @_S? then return @_S
		@_S = 0
		if @serieBrute?
			@_S += val for val in @serieBrute
		else
			@_S += item.value*item.effectif for item in @serie
		@_S
	sum_sq: ->
		if @_S2? then return @_S2
		@_S2 = 0
		if @serieBrute?
			@_S2 += val*val for val in @serieBrute
		else
			@_S2 += item.value*item.value*item.effectif for item in @serie
		@_S2
	moyenne: ->
		if @N() is 0 then return NaN
		@sum()/@N()
	variance: ->
		if @N() is 0 then return NaN
		moyenne = @moyenne()
		@sum_sq()/@N()-moyenne*moyenne
	std: -> Math.sqrt(@variance())
	getRank: (rank) ->
		if (rank>@N()) or (rank<=0) then return NaN
		@sort()
		if @serieBrute then return @serieBrute[rank-1]
		for item in  @serie
			if item.ECC >= rank then return item.value
		NaN
	mediane: ->
		if @N() is 0 then return NaN
		pair = false
		@sort()
		if @N()%2 then (@getRank(@N()/2-1)+@getRank(@N()/2))/2
		else @getRank((@N()-1)/2)
	fractile: (tranche, nb_tranches) ->
		if @N() is 0 then return NaN
		if (tranche>nb_tranches) or (tranche<0) then return NaN
		@sort()
		@getRank ( Math.ceil(tranche/nb_tranches*(@N()-1)) )
	max: ->
		if @N() is 0 then return NaN
		if @serieBrute? then Math.max(@serieBrute)
		else
			@sort()
			@serie[@serie.length-1].value
	min: ->
		if @N() is 0 then NaN
		if @serieBrute? then Math.min(@serieBrute)
		else
			@sort()
			@serie[0].value
	countEffectifs: ()->
		if @N() is 0 then return []
		@sort()
		if @_alreadyCounted? then return @serie
		@_alreadyCounted = true
		if @serieBrute?
			@serie = []
			item = { value:@serieBrute[0], effectif:0, ECC:0 }
			@serie.push item
			for value in @serieBrute
				if value is item.value
					item.effectif++
					item.ECC++
				else
					item = { value:value, effectif:1, ECC:item.ECC+1 }
					@serie.push item
			@serieBrute = null
		else
			@serie[0].ECC = @serie[0].effectif
			i=1
			while i<@serie.length
				if (@serie[i-1].value is @serie[i].value)
					@serie[i-1].ECC += @serie[i].effectif
					@serie.slice(i,1)
				else
					@serie[i].ECC = @serie[i].effectif
					i++
		@serie
	storeInString: ->
		if @serieBrute? then return @serieBrute.join(";")
		liste_str = ( item.value+"|"+item.effectif for item in @serie )
		return liste_str.join(";")
	###
	stringRegroup: (n)->
		# Afin de créer des exos, on prévoit de regrouper en n valeurs différentes, maximum
		# en répprochant les valeurs les plus proches
		@dists = []
		@sort()
		i=0
		while i<@serie.length-1
			@dists[i] = Math.abs(@serie[i+1]-@serie[i])
			i++
		@dists.sort (a,b)->
			if a>=b then return -1
			1
		# On a les distances dans l'ordre décroissant.
		# Puisqu'on ne veut que n valeurs max, on va considérer que les n-1 plus grandes
		# distances constituent une vraie différence et que les suivantes doivent être colmatées.
		if n>@dists.length then return @
		D0 = @dists[n-1]
		# Une différence de D0 ou moins n'en est pas une.
		if D0 is 0 then return @
		i=0
		item = {sum: @serie[0], eff:1 }
		nouvelleSerie = [ item ]
		while i<@serie.length-1
			if Math.abs(@serie[i+1]-@serie[i])<=D0
				# Cette différence doit être annulée
				item.sum += @serie[i+1]
				item.eff += 1
			else
				item = {sum: @serie[i+1], eff:1 }
				nouvelleSerie.push item
		@serie = (item.sum/item.eff for item in nouvelleSerie)
		@
	###
	approx: (delta) ->
		@refresh()
		if @serieBrute? then @serieBrute = ( Math.round(value/delta)*delta for value in @serie )
		else
			@serie = ( Math.round(item.value/delta)*delta for item in @serie )
			@countEffectifs()
		@
	toStr: (decimals) ->
		if @serieBrute? then return ( value.toStr(decimals) for value in @serieBrute)
		else return ({ value:item.value.toStr(decimals), effectif:item.effectif, ECC:item.ECC } for item in @serie)
	getEffectifs: (values) ->
		# renvoie les effectifs pour une table de valeurs
		i=0
		effectifs = []
		if @serieBrute?
			for value in values
				eff = 0
				i++ while (i<@serieBrute.length) and (@serieBrute[i]<value)
				while (i<@serieBrute.length) and (@serieBrute[i] is value)
					eff += 1
					i++
				effectifs.push(eff)
		else
			for value in values
				eff = 0
				i++ while (i<@serie.length) and (@serie[i].value<value)
				while (i<@serie.length) and (@serie[i].value is value)
					eff += @serie[i].effectif
					i++
				effectifs.push(eff)
		effectifs
