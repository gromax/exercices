
class @Suite
	nMin:0
	u_nMin:null
	recurence:null
	exlplicite:null
	nom:"u"
	constructor: (@nom,nMin)->
		if nMin? then @nMin = nMin
	@geometrique: (nom,premier,q,rangPremier) ->
		u = new Suite(nom,rangPremier)
		u.q = NumberManager.makeNumber(q)
		u.u_nMin = NumberManager.makeNumber(premier)
		u.recurence = (x) -> @q.toClone().md(x,false)
		u.explicite = (x) -> @u_nMin.toClone().md(PowerNumber.make(@q.toClone(),x.am(new RealNumber(@nMin),true)),false )
		u
	@arithmetique: (nom,premier,r,rangPremier) ->
		u = new Suite(nom,rangPremier)
		u.r = NumberManager.makeNumber(r)
		u.u_nMin = NumberManager.makeNumber(premier)
		u.recurence = (x) -> x.toClone().am(@r,false)
		u.explicite = (x) -> @u_nMin.toClone().am(MultiplyNumber.makeMult([x.am(new RealNumber(@nMin),true),@r.toClone()]),false )
		u
	@aritmeticogeometrique: (nom,premier,r,q,rangPremier) ->
		q = NumberManager.makeNumber(q)
		if q.toNumber() is 1  then return @arithmetique(nom,premier,r,rangPremier)
		u = new Suite(nom,rangPremier)
		u.r = NumberManager.makeNumber(r)
		u.q = q
		u.h = u.r.toClone().md(u.q.toClone().am(new RealNumber(1),true),true)
		u.u_nMin = NumberManager.makeNumber(premier)
		u.v_nMin = u.u_nMin.toClone().am(u.h,false)
		u.recurence = (x) -> @q.toClone().md(x,false).am(@r,false)
		u.explicite = (x) -> @v_nMin.toClone().md(PowerNumber.make(@q.toClone(),x.am(new RealNumber(@nMin),true)),false ).am(@h,false)
		u
	n: (x) ->
		if x? then NumberManager.makeNumber(x)
		else NumberManager.makeSymbol("n")
	un: () -> NumberManager.makeSymbol(@nom+"_n")
	tex_rec: () ->
		if @recurence isnt null then @recurence(@un()).simplify().tex()
		else "?"
	tex_expl: () ->
		if @explicite isnt null then @explicite(@n()).simplify().tex()
		else "?"
