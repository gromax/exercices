
Exercice.liste.push
	id:24
	title:"Loi binomiale"
	description:"Calculer des probabilités avec la loi binomiale."
	keyWords:["probabilités","binomiale","Première"]
	init: (data) ->
		inp = data.inputs
		h_init("n",inp,10,40)
		if (typeof inp.p is "undefined") then inp.p = mM.alea.real({min:1, max:99})/100
		else inp.p = Number inp.p
		if (typeof inp.k is "undefined") then inp.k = Math.round(inp.n*inp.p)
		else k = Math.min(Number inp.k, inp.n-1)
		pXegalK_good = mM.distribution.binomial(inp.n, inp.p, inp.k)
		pXinfK_good = mM.repartition.binomial(inp.n,inp.p,inp.k)
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>La variable aléatoire $X$ suit la loi binomiale de paramètres $n=#{inp.n}$ et $p=#{numToStr inp.p, 2}$, autrement dit $\\mathcal{B}(#{inp.n};#{numToStr inp.p, 2})$.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Calculs de probabilités"
				liste:[
					{
						tag:"$p(X=#{inp.k})=$"
						name:"pXegalK"
						description:"Valeur à 0,001 près"
						good:pXegalK_good
						arrondi:-3
					}
					{
						tag:"$p(X\\leqslant #{inp.k})=$"
						name:"pXinfK"
						description:"Valeur à 0,001 près"
						good:pXinfK_good
						arrondi:-3
					}
				]
				aide: oHelp.proba.binomiale.calculette
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			out.push {
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre:"La variable $X$ suit la loi binomiale de paramètres : $n=#{itData.inputs.n}$ et $p=#{numToStr itData.inputs.p, 2}$."
					items: ["Donnez $p(X=#{itData.inputs.k})$ à $0,001$ près.", "Donnez $p(X\\leqslant #{itData.inputs.k})$"]
				}
			}
		out
