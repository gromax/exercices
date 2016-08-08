
Exercice.liste.push
	id:28
	title:"Dériver une fonction"
	description:"Une fonction polynome est donnée, il faut la dériver."
	keyWords:["Analyse", "fonction", "Dérivation", "Première"]
	init: (data) ->
		if (typeof data.inputs.poly is "undefined")
			degre = Proba.aleaEntreBornes(1,5)
			coeffs = []
			coeffs.push Proba.aleaEntreBornes(-7,7) for i in [0..degre]
			poly = Polynome.make(coeffs)
			data.inputs.poly = String poly
		else
			poly = Polynome.parse data.inputs.poly
		polyTex = poly.tex()
		derivee = poly.derivate()
		deriveeTex = derivee.tex()
		derivee = derivee.toNumberObject()
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Soit $f(x) = #{polyTex}$</p><p>Donnez l'expression de $f'$, fonction dérivée de $f$ sur $\\mathbb{R}$.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Expression de $f'$"
				liste:[{tag:"$f'(x)$", name:"d", description:"Expression de la dérivée", good:derivee, params:{developp:true}}]
				aide: oHelp.derivee.basics
			}
		]
