
Exercice.liste.push
	id:28
	title:"Dériver une fonction"
	description:"Une fonction polynome est donnée, il faut la dériver."
	keyWords:["Analyse", "fonction", "Dérivation", "Première"]
	options: {
		a:{ tag:"Avec ln" , options:["Sans", "ln(x)", "ln(ax+b)", "exp(x)", "exp(ax+b)"] , def:0 }
		d:{ tag:"Degré max du polynôme", options:[0,1,2,3,4,5], def:5 }
	}
	init: (data) ->
		# debug ancienne version
		if data.inputs.poly then data.inputs.fct = data.inputs.poly
		if (typeof data.inputs.fct is "undefined")
			opt = data.options
			if (opt.d.value is 0) then operands = [
				mM.alea.number { denominator:[1,2,3], values:{ min:-10, max:10} }
			]
			else operands = [
				mM.alea.poly { degre:{min:1, max:opt.d.value}, coeffDom:[1,2,3], denominators:[1,2,3], values:{ min:-10, max:10} }
			]
			if (opt.a.value is 1) or (opt.a.value is 2)
				# Il y aura un ln que l'on va multiplier au pire par du degré 2
				operands.push mM.alea.poly({ degre:[0,1,2], coeffDom:[1,2,3], denominators:[1,2], values:{ min:-10, max:10} })
				if opt.a.value is 2 then operands.push mM.alea.poly({ degre:1, coeffDom:{min:1, max:10}, values:{min:-10, max:10} })
				else operands.push "x"
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

		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Soit $f(x) = #{tex}$</p><p>Donnez l'expression de $f'$, fonction dérivée de $f$ sur $\\mathbb{R}$.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Expression de $f'$"
				liste:[{tag:"$f'(x)$", name:"d", description:"Expression de la dérivée", good:derivee, params:{developp:true, tex:deriveeForTex.tex(), formes:{ fraction:true, distribution:true} }}]
				aide: oHelp.derivee.basics
			}
		]
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] { items: ("$x \\mapsto #{item.fct}$" for item in data), large:slide is true }
		}
