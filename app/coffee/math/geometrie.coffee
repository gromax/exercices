
class @Vector
	@makeRandoms: (tags, data, params) -> ( @makeRandom tag, data, params for tag in tags )
	@makeRandom: (tag, data, params) ->
		if typeof tag is "object"
			tagParam = tag
			tag = tag.tag
		config = Tools.mergeMulti [{ overwrite:false, axes:["x", "y"], ext:[[-10,10]], name:tag, save:true }, params, tagParam]
		coords = {}
		unless data? then data = {}
		for axe,i in config.axes
			if i<config.ext.length then [min,max] = config.ext[i]
			else [min,max] = config.ext[0]
			if (typeof data[axe+tag] is "undefined") or config.overwrite
				if config.def? then coords[axe] = NumberManager.makeNumber config.def[axe]
				else
					if config.deno? then coords[axe] = NumberManager.makeNumber { numerator:Proba.aleaEntreBornes(min*config.deno,max*config.deno), denominator:config.deno }
					else coords[axe] = NumberManager.makeNumber(Proba.aleaEntreBornes(min,max))
				if config.save then data[axe+tag] =coords[axe].toString()
			else
				coords[axe] = NumberManager.makeNumber(data[axe+tag])
		#config.graph ???
		return new Vector config.name, coords
	constructor: (@name,coords) ->
		@x = NumberManager.makeNumber(coords.x)
		@y = NumberManager.makeNumber(coords.y)
		if coords.z? then @z = NumberManager.makeNumber(coords.z)
		else @z = null
	setName : (name) ->
		@name = name
		@
	toClone: (newName) ->
		if typeof newName isnt "string" then newName = @name
		new Vector newName, {x:@x.toClone(), y:@y.toClone(), z:@z?.toClone() }
	sameAs: (oVec,axe) ->
		if typeof axe is "undefined" then return @sameAs(oVec,"x") and @sameAs(oVec,"y") and @sameAs(oVec,"z")
		if axe is "z"
			if (@z is null) and (oVec.z is null) then return true
			if (@z isnt null) and (oVec.z isnt null) then return NumberManager.equal @z, oVec.z
			return false
		return NumberManager.equal @[axe], oVec[axe]
	am: (oVec, sub=false) ->
		@x = @x.am oVec.x, sub
		@y = @y.am oVec.y, sub
		if (@z is null) or (oVec.z is null) then @z = null
		else @z = @z.am oVec.z, sub
		@
	mdNumber: (num, div=false) ->
		num = NumberManager.makeNumber num
		@x = @x.md num, div
		@y = @y.md num, div
		if @z isnt null then @z = @z.md num, div
		@
	milieu: (oVec,milName) -> @toClone(milName).am(oVec, false).mdNumber(2,true)
	symetrique: (centre,symName) -> centre.toClone(symName).mdNumber(2,false).am(@, true)
	texColumn: ->
		output = @name+"\\begin{pmatrix} #{@x.tex()}\\\\ #{@y.tex()}"
		if @z isnt null then output+= "\\\\ #{@z.tex()}"
		output += "\\end{pmatrix}"
		output
	texLine: ->
		output = @name+"\\left(#{@x.tex()};#{@y.tex()}"
		if @z isnt null then output += ";#{@z.tex()}"
		output+="\\right)"
		output
	toString: ->
		output = @name+"(#{@x};#{@y}"
		if @z isnt null then output += ";#{@z}"
		output+=")"
		output
	texFunc: (fName) ->
		# pour une écriture de type f(x)=y
		return fName+"\\left(#{@x.tex()}\\right) = #{@y.tex()}"
	simplify: ->
		@x = @x.simplify()
		@y = @y.simplify()
		if @z isnt null then @z = @z.simplify()
		@
	aligned: (B,C) -> @toClone().am(B,true).colinear @toClone().am(C,true)
	colinear: (oVec) ->
		if not NumberManager.equal @x.toClone().md(oVec.y,false), @y.toClone().md(oVec.x,false) then return false
		if (@z is null) and (oVec.z is null) then return true
		if (@z isnt null) and (oVec.z isnt null) and NumberManager.equal @x.toClone().md(oVec.z,false), @z.toClone().md(oVec.x,false) then return true
		false
	norme: ->
		d2 = @x.toClone().md(@x,false).am(@y.toClone().md(@y,false),false)
		if @z isnt null then d2=d2.am(@z.toClone().md(@z,false),false)
		d2.sqrt()
	affixe: -> return @y.toClone().md(new ComplexeNumber(0,1),false).am(@x,false)
	toJSXcoords: () -> [@x.toNumber(), @y.toNumber()]
class @Droite2D
	@par2Pts: (pt1, pt2) ->
		uDir = pt2.toClone().am pt1, true
		a = uDir.y
		b = uDir.x.opposite()
		pt = pt1.toClone()
		c = pt.x.md(a,false).opposite().am(pt.y.md(b,false),true) # c=-ax-by
		return new Droite2D a,b,c
	constructor: (a,b,c) ->
		# Représentation cartésienne
		@a = NumberManager.makeNumber a
		@b = NumberManager.makeNumber b
		@c = NumberManager.makeNumber c
		@_a = @a.toNumber()
		@_b = @b.toNumber()
		@_c = @c.toNumber()
	verticale: -> @b.isNul()
	m: -> @a.toClone().opposite().md @b, true
	p: -> @c.toClone().opposite().md @b, true
	k: -> @c.toClone().opposite().md @a, true
	toNumberObject : ->
		numA = @a.toClone().md(NumberManager.makeSymbol "x", false)
		numB = @b.toClone().md(NumberManager.makeSymbol "y", false)
		numObj = numA.am(numA,false).am(@c,false).simplify()
	toString: -> @toNumberObject().toString()+"=0"
	cartesianTex: -> @toNumberObject().tex()+"=0"
	reduiteObject: (variable) ->
		# permet de récupérer un objet à comparer avec une saisie utilisateur par exemple
		if @verticale() then return @k()
		unless variable? then variable = "x"
		return @m().md(NumberManager.makeSymbol variable, false).am(@p(),false).simplify()
	reduiteTex: (name) ->
		if @verticale() then out = "x="+@k().tex()
		else out = "y="+@m().md(NumberManager.makeSymbol "x", false).am(@p(),false).simplify().order(false).tex()
		if name? then return name+":"+out
		out
	affineTex: (name="f", variable="x", mapsto=false) ->
		if (name isnt "") and mapsto then name = name+":"
		if @verticale()
			if mapsto then return name+variable+"\\mapsto ?"
			else return name+"("+variable+")=?"
		out =@m().md(NumberManager.makeSymbol variable, false).am(@p(),false).simplify().order(false).tex()
		if mapsto then return name+variable+"\\mapsto "+out
		name+"("+variable+")="+out
	float_distance: (x,y) -> Math.abs(@_a*x+@_b*y+@_c) / Math.sqrt(@_a*@_a+@_b*@_b)
	float_y: (x) ->
		if @_b is 0 then return Number.NaN
		(-x*@_a-@_c)/@_b
	float_x: (y) ->
		if @_a is 0 then return Number.NaN
		(-y*@_b-@_c)/@_a
	float_2_points: (M)->
		# Donne les coordonnées de deux points pour permettre le tracé
		if @_b is 0 then [[-@_a / @_c,-M ],[ -@_a / @_c,M]]
		else [[-M, (M*@_a-@_c) / @_b ],[M, -(M*@_a+@_c)/@_b ]]

