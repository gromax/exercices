
class Suite
	nMin:0
	u_nMin:null
	recurence_def:null
	exlplicite_def:null
	nom:"u"
	constructor: (@nom,nMin,u_nMin,expl,recur)->
		if nMin? then @nMin = nMin
		if isArray(u_nMin) then @u_nMin = u_nMin else @u_nMin = []
		if typeof expl is "function" then @explicite_def = expl
		if typeof recur is "function" then @recurence_def = recur
	set:(name,value)->
		@[name] = value
		@
	calc:(n,forceRecur=false) ->
		# n est un nombre
		# forceRecur permet de forcer l'utilisation de la formerécurrente
		if n<@nMin then return new RealNumber()
		if n<@nMin+@u_nMin.length then return @u_nMin[n-@nMin].toClone()
		if (not (forceRecur and (@recurence_def isnt null) )) and (@explicite_def isnt null) then return @explicite_def(new RealNumber n).simplify()
		if @recurence_def isnt null
			k = @recurence_def.length
			if k>@u_nMin.length then return new RealNumber()
			while (l=@u_nMin.length)<=n-@nMin
				@u_nMin.push @recurence_def(@u_nMin[-k..]...).simplify()
			return @u_nMin[n-@nMin]
		return new RealNumber()
	un: (i=0) ->
		if i is 0 then SymbolManager.makeSymbol("#{@nom}_n")
		else SymbolManager.makeSymbol("#{@nom}_{n+#{i}}")
	recurence: (args) ->
		if @recurence_def isnt null
			k = @recurence_def.length
			if (not isArray(args)) or (args.length<k) then args = ( @un(i) for i in [0..k-1] )
			@recurence_def(args...).simplify()
		else new NumberObject()
	explicite: (x) ->
		if typeof x is "number" then x = new RealNumber(x)
		if not(x instanceof NumberObject) then x = SymbolManager.makeSymbol("n")
		if @explicite_def isnt null then @explicite_def(x).simplify()
		else new NumberObject()
