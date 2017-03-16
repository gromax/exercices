
Exercice.liste.push
	id:49
	title:"Donnez la primitive d'une fonction"
	description:"Une fonction polynome est donnée, il faut donner sa primitive."
	keyWords:["Analyse", "fonction", "Primitive", "Terminale"]
	init: (data) ->
		if (typeof data.inputs.poly is "undefined")
			degre = mM.alea.real { min:1, max:4 }
			coeffs = [ 0 ]
			coeffs.push mM.alea.real({ min:-7, max:7 }) for i in [0..degre-1]
			poly = mM.polynome.make { coeffs:coeffs }
			data.inputs.poly = String poly
		else
			poly = mM.polynome.make data.inputs.poly
		polyTex = poly.tex()+"+c"
		derivee = poly.derivate()
		deriveeTex = data.f = derivee.tex()
		poly = mM.exec [poly.toNumberObject(), "symbol:c", "+"]
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Soit $f(x) = #{deriveeTex}$</p><p>Donnez l'expression générale de $F$, fonction primitive de $f$ sur $\\mathbb{R}$.</p><p><b>Attention :</b> : Utilisez la lettre $c$ pour la constante faisant la généralité de $F$.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Expression de $F$"
				liste:[{
					tag:"$F(x)$", name:"p"
					description:"Expression de la primitive"
					good:poly
					developp:true
					toLowercase:true
					customVerif:(userObject,goodObject,verif_result)->
						if mM.exec([goodObject, "symbol:c", "-", userObject, "-"], {simplify:true}).isNul()
							verif_result.manque_constante_c = true
							verif_result.ponderation = .5
					customTemplate: (verif_result) ->
						if verif_result.manque_constante_c then ["Vous avez oublié la constante $c$."]
						else []
				}]
				#aide: oHelp.derivee.basics
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] { items: ("$x \\mapsto #{item.f}$" for item in data), large:false }
		}
