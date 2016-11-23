
class @SerieStat
	brut:true
	sorted:false
	counted:false
	ECC_counted:false
	_N:null
	_S:null
	_S2:null
	constructor: (liste) ->
		@serie = []
		if isArray(liste)
			for item in liste
				if typeof item is "number" then @serie.push { value:item, effectif:1 }
				else @serie.push item
		else if typeof liste is "object"
			values = liste.values
			effectifs = liste.effectifs
			if isArray(values) and isArray(effectifs)
				ne = effectifs.length
				for value,i in values
					if (i<ne) then @serie.push { value:value, effectif:effectifs[i] }
					else @serie.push { value:value, effectif:1 }
		else if typeof liste is "string" then @makeFromString(liste)
	transform:(fct) -> new SerieStat ( { value:fct(item.value), effectif:item.effectif} for item in @serie )
	makeFromString: (liste) ->
		table = liste.split(";")
		@serie = []
		for item in table
			item_arr = item.split("|")
			if item_arr.length is 2
				effectif = Number(item_arr[1])
				value = Number(item_arr[0])
			else
				value = item_arr[0]
				effectif = 1
			@serie.push { value:value, effectif:effectif }
			if effectif > 1 then @brut = false
	refresh: ->
		@_N = null
		@_S = null
		@_S2 = null
		@sorted = false
		@counted = false
		@ECC_counted = false
		@
	sort: ->
		if not @sorted
			@serie.sort (a,b) ->
				if a.value>=b.value then return 1
				else -1
			@sorted = true
		@
	ECC: ->
		if @ECC_counted then return @
		@sort()
		ECC = 0
		for item in @serie
			ECC += item.effectif
			item.ECC = ECC
		@ECC_counted = true
		@
	N: ->
		if @_N? then return @_N
		@_N=0
		@_N += item.effectif for item in @serie
		@_N
	sum: ->
		if @_S? then return @_S
		@_S = 0
		@_S += item.value*item.effectif for item in @serie
		@_S
	sum_sq: ->
		if @_S2? then return @_S2
		@_S2 = 0
		@_S2 += item.value*item.value*item.effectif for item in @serie
		@_S2
	sum_xy: (sy) ->
		unless sy instanceof SerieStat then return NaN
		n = Math.min(@N(),sy.N())
		s = 0
		index_x = index_y = -1
		i = ECx = ECy = 0
		for i in [0..n-1]
			if i>= ECx
				index_x++
				item_x = @serie[index_x]
				ECx += item_x.effectif
			if i>= ECy
				index_y++
				item_y = sy.serie[index_y]
				ECy += item_y.effectif
			s += item_x.value * item_y.value
		s
	moyenne: ->
		if @N() is 0 then return NaN
		@sum()/@N()
	variance: ->
		if @N() is 0 then return NaN
		moyenne = @moyenne()
		@sum_sq()/@N()-moyenne*moyenne
	covariance: (sy) ->
		unless sy instanceof SerieStat then return NaN
		n = Math.min(@N(),sy.N())
		if n is 0 then return NaN
		@sum_xy(sy)/n-@moyenne()*sy.moyenne()
	std: -> Math.sqrt(@variance())
	ajustement: (sy,decimals) ->
		cov = @covariance(sy)
		v = @variance()
		a = cov / v
		b = sy.moyenne() - a*@moyenne()
		r = cov / (@std()*sy.std())
		if decimals? then { a:fixNumber(a,decimals), b:fixNumber(b,decimals), r:r }
		else {a:a, b:b, r:r}
	getRank: (rank) ->
		N = @N()
		if (rank>N) or (rank<=0) then return NaN
		@ECC()
		for item in  @serie
			if item.ECC >= rank then return item.value
		NaN
	mediane: ->
		if @N() is 0 then return NaN
		pair = (@N()%2 is 0)
		if pair then (@getRank(@N()/2-1)+@getRank(@N()/2))/2
		else @getRank((@N()-1)/2)
	fractile: (tranche, nb_tranches) ->
		if @N() is 0 then return NaN
		if (tranche>nb_tranches) or (tranche<0) then return NaN
		@getRank ( Math.ceil(tranche/nb_tranches*(@N()-1)) )
	max: ->
		if @N() is 0 then return NaN
		@sort()
		@serie[@serie.length-1].value
	min: ->
		if @N() is 0 then return NaN
		@sort()
		@serie[0].value
	countEffectifs: ()->
		if @counted then return @
		@ECC() # calcule les ECC
		i=1
		while i<@serie.length
			if (@serie[i-1].value is @serie[i].value)
				@serie[i-1].ECC += @serie[i].effectif
				@serie[i-1].effectif += @serie[i].effectif
				@serie.splice(i,1)
			else i++
		@
	storeInString: ->
		liste = []
		for item in @serie
			if item.effectif is 1 then liste.push String(item.value)
			else liste.push item.value+"|"+item.effectif
		liste.join(";")
	approx: (delta) ->
		@refresh()
		@serie = ( Math.round(item.value/delta)*delta for item in @serie )
		@countEffectifs()
		@
	toStringArray: (decimals) ->
		({
			value: if decimals? then item.value.toFixed(decimals).replace(".", ",") else String(item.value)
			effectif:item.effectif
			ECC:item.ECC
			} for item in @serie)
	getEffectifs: (values) ->
		# renvoie les effectifs pour une table de valeurs
		i=0
		effectifs = []
		@sort()
		if values?
			for value in values
				eff = 0
				i++ while (i<@serie.length) and (@serie[i].value<value)
				while (i<@serie.length) and (@serie[i].value is value)
					eff += @serie[i].effectif
					i++
				effectifs.push(eff)
		else
			effectifs.push item.effectif for item in @serie
		effectifs
	getValues: () -> ( item.value for item in @serie )
