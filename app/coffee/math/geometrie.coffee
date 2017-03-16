
class Vector
	constructor: (@name,coords) ->
		@x = coords.x
		@y = coords.y
		if coords.z? then @z = coords.z
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
			if (@z isnt null) and (oVec.z isnt null) then return @z.toClone().am(oVec.z, true).simplify().isNul()
			return false
		return @[axe].toClone().am(oVec[axe],true).simplify().isNul()
	plus: (oVec) -> @am(oVec,false)
	minus: (oVec) -> @am(oVec,true)
	am: (oVec, sub=false) ->
		@x = @x.am oVec.x, sub
		@y = @y.am oVec.y, sub
		if (@z is null) or (oVec.z is null) then @z = null
		else @z = @z.am oVec.z, sub
		@
	mdNumber: (numObj, div=false) ->
		@x = @x.md numObj, div
		@y = @y.md numObj, div
		if @z isnt null then @z = @z.md numObj, div
		@
	milieu: (oVec,milName) -> @toClone(milName).am(oVec, false).mdNumber(new RealNumber(2),true)
	symetrique: (centre,symName) -> centre.toClone(symName).mdNumber(new RealNumber(2),false).am(@, true)
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
		if not @x.toClone().md(oVec.y,false).am(@y.toClone().md(oVec.x,false),true).isNul() then return false
		if (@z is null) and (oVec.z is null) then return true
		if (@z isnt null) and (oVec.z isnt null) and @x.toClone().md(oVec.z,false).am(@z.toClone().md(oVec.x,false),false) then return true
		false
	norme: ->
		d2 = @x.toClone().md(@x,false).am(@y.toClone().md(@y,false),false)
		if @z isnt null then d2=d2.am(@z.toClone().md(@z,false),false)
		d2.sqrt()
	affixe: -> return @y.toClone().md(new ComplexeNumber(0,1),false).am(@x,false)
	toJSXcoords: (params) -> mM.float [@x, @y], params
	save: (data) ->
		data["x#{@name}"] = String @x
		data["y#{@name}"] = String @y
		if @z isnt null then data["z#{name}"] = String @z
		@
class Droite2D
	constructor: ( param ) ->
		if param?
			if isArray(param)
				@a = param[0]
				@b = param[1]
				@c = param[2]
			else
				# C'est un numberobject
				@a = param.derivate "x"
				@b = param.derivate "y"
				vx = new Monome(@a.toClone(), {name:"x", power:1})
				vy = new Monome(@b.toClone(), {name:"y", power:1})
				@c = vx.am(vy,false).opposite().am(param,false)
		else
			@a = new RealNumber(0)
			@b = new RealNumber(0)
			@c = new RealNumber(0)
		# Représentation cartésienne
	verticale: -> @b.isNul()
	m: -> @a.toClone().opposite().md @b, true
	p: -> @c.toClone().opposite().md @b, true
	k: -> @c.toClone().opposite().md @a, true
	toNumberObject : -> mM.exec [@a, "x", "*", @b, "*", @c, "+", "+"], { simplify:true }
	toString: -> @toNumberObject().toString()+"=0"
	cartesianTex: -> @toNumberObject().tex()+"=0"
	reduiteObject: (variable) ->
		# permet de récupérer un objet à comparer avec une saisie utilisateur par exemple
		if @verticale() then return @k()
		unless variable? then variable = "x"
		return mM.exec [@m(), "symbol:#{variable}", "*", @p(), "+"], { simplify:true }
	reduiteTex: (name) ->
		tag = if name? then name+":" else ""
		if @verticale() then "#{tag}x=#{@k().tex()}"
		else "#{tag}y=#{ mM.exec([ @m(), "x", "*", @p(), "+"], { simplify:true }).tex() }"
	affineTex: (name="f", variable="x", mapsto=false) ->
		if (name isnt "") and mapsto then name = name+":"
		if @verticale()
			if mapsto then return name+variable+"\\mapsto ?"
			else return name+"("+variable+")=?"
		out = @reduiteObject(variable)
		if mapsto then "#{name}#{variable}\\mapsto #{out.tex()}"
		else "#{name}(#{variable})=#{out.tex()}"
	float_distance: (x,y, params) ->
		[_a, _b, _c] = mM.float [@a, @b, @c], params
		Math.abs(_a*x+_b*y+_c) / Math.sqrt(_a*_a+_b*_b)
	float_y: (x, params) ->
		[_a, _b, _c] = mM.float [@a, @b, @c], params
		if _b is 0 then return Number.NaN
		(-x*_a-_c)/_b
	float_x: (y,params) ->
		[_a, _b, _c] = mM.float [@a, @b, @c], params
		if _a is 0 then return Number.NaN
		(-y*_b-_c)/_a
	float_2_points: (M, params)->
		# Donne les coordonnées de deux points pour permettre le tracé
		[_a, _b, _c] = mM.float [@a, @b, @c], params
		if _b is 0 then [[-_a / _c,-M ],[ -_a / _c,M]]
		else [[-M, (M*_a-_c) / _b ],[M, -(M*_a+_c)/_b ]]
	isEqual: (droite) ->
		d1 = @a.toClone().md(droite.b,false).am(@b.toClone().md(droite.a,false),true)
		d2 = @a.toClone().md(droite.c,false).am(@c.toClone().md(droite.a,false),true)
		d3 = @b.toClone().md(droite.c,false).am(@c.toClone().md(droite.b,false),true)
		return d1.isNul() and d2.isNul() and d3.isNul()



