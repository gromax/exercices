
Exercice.liste.push
	id:28
	title:"Dériver une fonction"
	description:"Une fonction polynome est donnée, il faut la dériver."
	keyWords:["Analyse", "fonction", "Dérivation", "Première"]
	options: {
		a:{ tag:"Avec ln ou exp" , options:["Sans", "ln(x)", "ln(ax+b)", "exp(x)", "exp(ax+b)"] , def:0 }
		d:{ tag:"Degré max du polynôme", options:[0,1,2,3,4,5], def:5 }
		e:{ tag:"Tangente", options:["non", "oui"], def:0}
	}
	init: (data) ->
		opt = data.options
		xmin = -10
		# debug ancienne version
		if data.inputs.poly then data.inputs.fct = data.inputs.poly
		if (typeof data.inputs.fct is "undefined")
			if (opt.d.value is 0) then operands = [
				mM.alea.number { denominator:[1,2,3], values:{ min:-10, max:10} }
			]
			else operands = [
				mM.alea.poly { degre:{min:1, max:opt.d.value}, coeffDom:[1,2,3], denominators:[1,2,3], values:{ min:-10, max:10} }
			]
			if (opt.a.value is 1) or (opt.a.value is 2)
				# Il y aura un ln que l'on va multiplier pae :
				# Soit du a, soiut ax, soit du ax^2+bx,au pire par du degré 2
				if mM.alea.dice(2,3) then coeff = mM.exec [ mM.alea.poly({ degre:[0,1], coeffDom:[1,2,3], values:{ min:-10, max:10} }), "x", "*" ], { simplify:true, developp:true }
				else coeff = mM.alea.number { denominators:[1,2], values:{ min:-10, max:10} }
				operands.push coeff
				if opt.a.value is 2
					a = mM.alea.real {min:1, max:10}
					b = mM.alea.real {min:-10, max:10}
					xmin = -b/a+1 # Pour l'éventuel calcul de tangente
					operands.push(a,"x","*",b,"+")
				else
					operands.push "x"
					xmin = 1 # Pour l'éventuel calcul de tangente
				operands.push "ln", "*", "+"

			if (opt.a.value is 3) or (opt.a.value is 4)
				# Il y aura un exp que l'on va multiplier avec le polynome
				if opt.a.value is 4 then operands.push mM.alea.poly({ degre:1, coeffDom:{min:1, max:10}, values:{min:-10, max:10} })
				else operands.push "x"
				operands.push "exp", "*"
			fct = mM.exec operands, { simplify:true }
			data.inputs.fct = String fct
		else fct = mM.parse(data.inputs.fct)
		tex = data.fct = fct.tex()
		derivee = fct.derivate("x").simplify(null,true)
		# On produit une version factorisée pour avoir une version idéale du tex
		deriveeForTex = mM.factorisation derivee, /// exp\(([x*+-\d]+)\)$ ///i, { simplify:true, developp:true }

		out = [
			new BEnonce {zones:[{body:"enonce", html:"<p>Soit $f(x) = #{tex}$</p><p>Donnez l'expression de $f'$, fonction dérivée de $f$ sur $\\mathbb{R}$.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Expression de $f'$"
				liste:[{
					tag:"$f'(x)$"
					name:"d"
					description:"Expression de la dérivée"
					good:derivee
					params:{
						developp:true
						goodTex:deriveeForTex.tex()
						formes:{ fraction:true, distribution:true}
					}
				}]
				aide: oHelp.derivee.basics
			}
		]

		if opt.e.value is 1
			if (typeof data.inputs.x isnt "undefined") then x = Number data.inputs.x
			else
				x = mM.alea.real { min:xmin, max:Math.max(xmin+1,10) }
				data.inputs.x = String x
			fa = mM.float fct, { x:x, decimals:2 }
			f2a = mM.float derivee, { x:x, decimals:2 }
			t = mM.exec [f2a, "x", x, "-", "*", fa, "+"], {simplify:true, developp:true}
			out.push new BListe({
				data:data
				bareme:100
				title:"Calcul de $f(a)$ et $f'(a)$ en $a=#{x}$"
				liste:[
					{tag:"$f(#{x})$", name:"fa", description:"Valeur de f(a) à 0,01", good:fa, params:{ arrondi:-2 }}
					{tag:"$f'(#{x})$", name:"f2a", description:"Valeur de f'(a) à 0,01", good:f2a, params:{ arrondi:-2 }}
				]
			})
			out.push new BListe({
				data:data
				bareme:100
				title:"Équation de la tangente $\\mathcal{T}_{#{x}}$ à l'abscisse $#{x}$"
				liste:[{tag:"$y=$", name:"e", description:"Équation de la tangente", good:t, params:{developp:true, formes:"FRACTION", cor_prefix:"y="}}]
				aide:oHelp.derivee.tangente
			})
		out
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		if (data[0]?.options.e?.value is 1)
			{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre:"Dans tous les cas, déterminer l'expression de $f'(x)$ ; calulez $f(a)$ et $f'(a)$ à $0,01$ près ; déterminez la tangente à $\\mathcal{C}_f$ à l'abscisse $a$."
					items: ("$x \\mapsto #{item.fct}$ et $a=#{item.inputs.x}$" for item in data)
					large:slide is true
				}
			}
		else
			{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre: "Donnez les dérivées des fonctions suivantes :"
					items: ("$x \\mapsto #{item.fct}$" for item in data)
					large:slide is true
				}
			}
