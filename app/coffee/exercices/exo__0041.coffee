
Exercice.liste.push
	id:41
	title: "Termes d'une suite explicite"
	description: "Calculer les termes d'une suite donnée explicitement."
	keyWords:["Analyse", "Suite", "Première"]
	init: (data) ->
		# Debug_old_version
		if data.inputs.p? then data.inputs.p = data.inputs.p.replace "x", "n"
		# Fin debug
		if data.inputs.p? then poly = mM.toNumber(data.inputs.p)
		else
			poly = mM.alea.poly { variable:"n", degre:2, coeffDom:{ min:1, max:3, sign:true}, values: { min:1, max:20, sign:true} }
			data.inputs.p = String poly
		[u0, u1, u2, u10] = mM.float(poly, [ {n:0}, {n:1}, {n:2}, {n:10} ])
		expression = poly.tex()
		expression = "$u_n = #{poly.tex()}$"
		data.tex = { expression: expression }
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère la suite $(u_n)$ définie par #{expression} pour $n\\geqslant 0$.</p><p>On demande de calculer les termes suivants :</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Termes de la suite"
				liste:[{tag:"$u_0$", name:"u0", description:"Terme de rang 0", good:u0}, {tag:"$u_1$", name:"u1", description:"Terme de rang 1", good:u1}, {tag:"$u_2$", name:"u2", description:"Terme de rang 2", good:u2}, {tag:"$u_{10}$", name:"u10", description:"Terme de rang 10", good:u10}]
			}
		]
	tex: (data) ->
		symbs = ["","<","\\leqslant"]
		if not isArray(data) then data = [ data ]
		its = ( it.tex.expression for it in data )
		if its.length > 1 then [{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre:"Dans les cas suivants, calculez $u_0$, $u_1$, $u_2$ et $u_{10}$."
					items: its
					large:false
				}
			}]
		else [{
				title:@title
				content:Handlebars.templates["tex_plain"] {
					content: "Calculez $u_0$, $u_1$, $u_2$ et $u_{10}$ avec #{its[0]}."
					large:false
				}
			}]
