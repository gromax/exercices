
Exercice.liste.push
	id:59
	title:"Dériver une fonction : règles"
	description:"Utiliser une règle de dérivation : $u\\cdot v$, $u^n$, $\\frac{1}{u}$, etc."
	keyWords:["Analyse", "fonction", "Dérivation", "Première"]
	options: {
		a:{ tag:"ln ?", options:["non", "oui"], def:0}
		b:{ tag:"exp ?", options:["non", "oui"], def:0}
		c:{ tag:"sin/cos ?", options:["non", "oui"], def:0}
	}
	genererFonction: (type,t_autre) ->
		switch type
			when 4 then mM.exec [ mM.alea.real({min:0, max:5}), "x", "ln", "+"], { simplify:true }	# Du ln(x)
			when 5 then mM.exec [ mM.alea.real({min:1, max:5}), "x", "exp", "+"], { simplify:true }	# Du exp(x)
			when 6 then mM.exec [ mM.alea.real({min:0, max:5}), "x", "cos", "+"], { simplify:true }	# Du cos(x)
			when 7 then mM.exec [ mM.alea.real({min:0, max:5}), "x", "sin", "+"], { simplify:true }	# Du sin(x)
			when 9
				# t_autre permet de réagir en fonction du type de l'autre fonction dans les cas u,v
				# utilisé pour les dérivée avec ln (type 4)
				a = mM.alea.number {min:1,max:9}
				b = mM.alea.number {min:-9,max:9}
				p = mM.exec [ a, "x", "*", "x", "*", b, "x", "*", "+"]
				if t_autre isnt 4
					c = mM.alea.number {min:-9,max:9}
					p = mM.exec [ p, c, "+"]
				p.simplify()
			else
				# t_autre permet de réagir en fonction du type de l'autre fonction dans les cas u,v
				# utilisé pour les dérivée avec ln (type 4)
				a = mM.alea.number {min:1,max:9}
				p = mM.exec [ a, "x", "*", "x"]
				if t_autre isnt 4
					b = mM.alea.number {min:-9,max:9}
					p = mM.exec [ p, b, "+"]
				p.simplify()
	init: (data) ->
		opt = data.options
		# types possibles : u.v ; 1/u ; u/v ; u^n ; ln(u) ; exp(u) ; cos(u) ; sin(u)
		fonctions = []
		if opt.a.value isnt 0 then fonctions.push 4
		if opt.b.value isnt 0 then fonctions.push 5
		if opt.c.value isnt 0 then fonctions.push 6,7
		if data.inputs.t? then t = Number data.inputs.t
		else data.inputs.t = t = mM.alea.in([0,1,2,3].concat fonctions)
		# On ajoute 8 et 9 pour ax+b et ax²+bx+c
		fonctions.push 8,9
		fonctions = mM.alea.shuffle(fonctions)
		switch t
			when 0
				# type u.v, il faut donc déterminer u et v
				t_u = fonctions.pop()
				t_v = fonctions.pop()
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction t_u, t_v )
				if data.inputs.v? then v = mM.toNumber data.inputs.v
				else data.inputs.v = String( v = @genererFonction t_v, t_u )
				fct = mM.exec [u, v, "*"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = u\\cdot v$ dont la dérivée est $f'(x) = u'\\cdot v + u\\cdot v'$."]
				derivee = fct.derivate("x").simplify(null,true)
			when 1
				# type 1/u, il faut donc déterminer u
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction fonctions.pop() )
				fct = mM.exec [1, u, "/"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = \\frac{1}{u}$ dont la dérivée est $f'(x) = -\\frac{u'}{u^2}$."]
				derivee = mM.exec [u.derivate("x").simplify(null,true), "*-", u, 2, "^", "/"]
			when 2
				# type u/v, il faut donc déterminer u et v
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction mM.alea.in [8,9] )
				if data.inputs.v? then v = mM.toNumber data.inputs.v
				else data.inputs.v = String( v = @genererFonction mM.alea.in [8,9] )
				fct = mM.exec [u, v, "/"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = \\frac{u}{v}$ dont la dérivée est $f'(x) = \\frac{u'\\cdot v - u\\cdot v'}{v^2}$."]
				upDerivee = mM.exec [u.derivate("x"), v, "*", u, v.derivate("x"), "*", "-"], { simplify:true, developp:true, clone:true}
				derivee = mM.exec [upDerivee, v, 2, "^", "/"]
			when 3
				# type u^n, il faut donc déterminer u et n
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction fonctions.pop() )
				if data.inputs.n? then n = Number data.inputs.n
				else data.inputs.n = n = mM.alea.real {min:3, max:10}
				fct = mM.exec [u, n, "^"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = u^n$ dont la dérivée est $f'(x) = n\\cdot u' \\cdot u^{n-1}$."]
				deriveeFact = mM.exec [n, u.derivate("x"), "*"], {simplify:true, clone:true}
				derivee = mM.exec [deriveeFact, u, n-1, "^", "*"]
			when 4
				# type ln(u), il faut donc déterminer u
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String(u = @genererFonction(8))
				fct = mM.exec [u, "ln"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = \\ln(u)$ dont la dérivée est $f'(x) = \\frac{1}{u}$."]
				derivee = fct.derivate("x").simplify(null,true)
			when 5
				# type exp(u), il faut donc déterminer u
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction(8) )
				fct = mM.exec [u, "exp"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = \\exp(u)$ dont la dérivée est $f'(x) = u' \\cdot\\exp(u)$."]
				derivee = fct.derivate("x").simplify(null,true)
			when 6
				# type cos(u), il faut donc déterminer u
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction(8) )
				fct = mM.exec [u, "cos"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = \\cos(u)$ dont la dérivée est $f'(x) = -u' \\cdot\\sin(u)$."]
				derivee = fct.derivate("x").simplify(null,true)
			when 7
				# type sin(u), il faut donc déterminer u
				if data.inputs.u? then u = mM.toNumber data.inputs.u
				else data.inputs.u = String( u = @genererFonction(8) )
				# La fonction à dériver :
				fct = mM.exec [u, "sin"], {clone:true}
				#Aide :
				aide = ["Vous devez reconnaître une forme $f(x) = \\sin(u)$ dont la dérivée est $f'(x) = u' \\cdot\\cos(u)$."]
				derivee = fct.derivate("x").simplify(null,true)
		tex = data.fct = fct.tex()
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>Soit $f(x) = #{tex}$</p><p>Donnez l'expression de $f'$, fonction dérivée de $f$ sur $\\mathbb{R}$.</p>"}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Expression de $f'$"
				liste:[{
					tag:"$f'(x)$"
					name:"d"
					description:"Expression de la dérivée"
					good:derivee
					goodTex: derivee.tex({negPowerDown:true})
					formes:{ fraction:true, distribution:true }
				}]
				aide: aide
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Donnez les dérivées des fonctions suivantes :"
				items: ("$x \\mapsto #{item.fct}$" for item in data)
				large:false
			}
		}
