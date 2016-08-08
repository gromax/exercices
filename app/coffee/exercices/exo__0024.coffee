
Exercice.liste.push
	id:24
	title:"Loi binomiale"
	description:"Calculer des probabilités avec la loi binomiale."
	keyWords:["probabilités","binomiale","Première"]
	init: (data) ->
		inp = data.inputs
		h_init("n",inp,10,40)
		if (typeof inp.p is "undefined") then inp.p = Proba.aleaEntreBornes(1,99)/100
		else inp.p = Number inp.p
		if (typeof inp.k is "undefined") then inp.k = Math.round(inp.n*inp.p)
		else k = Math.min(Number inp.k, inp.n-1)
		pXegalK_good = Proba.binomial_density(inp.n,inp.p,inp.k)
		pXinfK_good = Proba.binomial_rep(inp.n,inp.p,inp.k)
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>La variable aléatoire $X$ suit la loi binomiale de paramètres $n=#{inp.n}$ et $p=#{inp.p.toStr(2)}$, autrement dit $\\mathcal{B}(#{inp.n};#{inp.p.toStr(2)})$.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Calculs de probabilités"
				liste:[{tag:"$p(X=#{inp.k})=$", name:"pXegalK", description:"Valeur à 0,001 près", good:Proba.binomial_density(inp.n,inp.p,inp.k), params:{arrondi:-3}}, {tag:"$p(X\\leqslant #{inp.k})=$", name:"pXinfK", description:"Valeur à 0,001 près", good:Proba.binomial_rep(inp.n,inp.p,inp.k), params:{arrondi:-3}}]
				aide: oHelp.proba.binomiale.calculette
			}
		]
