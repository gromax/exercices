
Exercice.liste.push
	id:49
	title:"Donnez la primitive d'une fonction"
	description:"Une fonction polynome est donnée, il faut donner sa primitive."
	keyWords:["Analyse", "fonction", "Primitive", "Terminale"]
	init: (data) ->
		if (typeof data.inputs.poly is "undefined")
			degre = Proba.aleaEntreBornes(1,4)
			coeffs = [ 0 ]
			coeffs.push Proba.aleaEntreBornes(-7,7) for i in [0..degre-1]
			poly = Polynome.make(coeffs)
			data.inputs.poly = String poly
		else
			poly = Polynome.parse data.inputs.poly
		polyTex = poly.tex()+"+c"
		derivee = poly.derivate()
		deriveeTex = derivee.tex()
		poly = poly.toNumberObject().am(NumberManager.makeSymbol("c"),false)
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
					params:{
						developp:true
						custom:(output)->
							if output.goodObject.toClone().am(NumberManager.makeSymbol("c"),true).am(output.userObject,true).simplify().isNul()
								output.manque_constante_c = true
								output.bareme = 50
						customTemplate:true
					}
				}]
				#aide: oHelp.derivee.basics
			}
		]
