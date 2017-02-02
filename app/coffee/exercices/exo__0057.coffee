
Exercice.liste.push
	id:57
	title:"Intervalle de fluctuation asymptotique"
	description:"Calculer un intervalle de fluctuation asymptotique."
	keyWords:["probabilités","binomiale","Intervalle de fluctuation","normale","TSTL"]
	init: (data) ->
		inp = data.inputs
		if (typeof inp.p is "undefined") then inp.p = p = mM.alea.real({min:1, max:12})
		else p = Number inp.p
		if (typeof inp.n is "undefined") then n=0 else n=inp.n
		if n*p<500 then inp.n = n = mM.alea.real({min:Math.ceil(500/p/50), max:20})*50
		sig = Math.sqrt(p*(100-p)/ n ) / 100
		fHigh = p/100+1.96*sig
		IF = mM.ensemble.intervalle "[", fixNumber(p/100-1.96*sig,3), fixNumber(fHigh,3), "]"
		# On fixe le nombre d'individus dans l'échantillon à un aléa entre 90 et 110% du max de l'intervalle de fluctuation.
		if (typeof inp.ne is "undefined") then inp.ne = ne = Math.round ( (100+mM.alea.real({min:-10, max:10})) * fHigh / 100 * n )
		else ne = Number inp.ne
		habillage = mM.alea.in [
			"Une usine fabrique des tuyaux en caoutchouc. On sait que #{p}% des tuyaux sont poreux. On prélève un échantillon de #{n} tuyaux dans la production qui est considérée comme assez importante. On a trouvé #{ne} tuyaux poreux dans l'échantillon. On appelle $f$ la fréquence de tuyaux poreux dans l'échantillon."
			"Une entreprise annonce que seulement #{p}% de ses clients exigent un remboursement. On interroge au hasard un échantillon de #{n} clients, en considérant que le nombre de clients est important. Dans l'échantillon, #{ne} clients ont éxigé un remboursement. On appelle $f$ la fréquence de clients dans l'échantillon ayant exigé un remboursement."
			"Une maladie affecte #{p}% de la population. On prélève au hasard un échantillon de #{n} personnes dans la population qui est considérée comme assez importante. #{ne} individus de l'échantillon étaient affectés par la maladie. On appelle $f$ la fréquence de personnes dans l'échantillon affectées par la maladie."
			"Un laboratoire affirme que son médicament a des effets secondaires dans #{p}% des cas. On prélève au hasard un échantillon de #{n} cas sur un nombre total assez important. Dans l'échantillon, il y a eu des effets secondaires dans #{ne} cas. On appelle $f$ la fréquence de cas dans l'échantillon présentant des effets secondaires."
		]
		isIn = (ne/n <= fHigh)
		data.tex = {
			habillage:habillage
			p:p
		}


		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>#{habillage}</p>"
				}
			]}
			new BListe {
				data:data
				bareme:100
				title:"Intervalle de fluctuation asymptotique à 95% de $f$"
				liste:[{
					tag:"$I_F$"
					name:"if"
					description:"Intervalle de fluctuation asymptotique à 0,001 = 0,1% près"
					good:IF
					large:true
					params:{arrondi:-3}
				}]
				aide: [
					"L'intervalle de fluctuation asymptotique est l'intervalle de fluctuation obtenu en approximant la loi $\\mathcal{B}(n;p)$ par une loi normale $\\mathcal{N}(\\mu;\\sigma)$, avec $\\mu = n\\cdot p$ et $\\sigma = \\sqrt{n\\cdot p \\cdot (1-p)}$"
					"L'intervalle de fluctuation à 95% pour $\\mathcal{N}(\\mu;\\sigma)$ est donné par $I_F = [ \\mu-1,96\\sigma ; \\mu+1,96\\sigma ]$"
					"On obtient directement :$I_F = \\left[p-1,96\\sqrt{\\frac{p \\cdot (1-p)}{n}} ; p+1,96\\sqrt{\\frac{p \\cdot (1-p)}{n}}\\right]$"
					"Cette formule est valable pour $n\\geqslant 30$ ; $n\\cdot p\\geqslant 5$ et $n\\cdot (1-p)\\geqslant 5$"
					"L'intervalle de fluctuation est un intervalle de fréquence. Il concerne la fréquence d'individus ayant la propriété voulue dans l'échantillon de $n$ individus."
				]
			}
			new BChoixMultiple {
				data:data
				bareme:40
				aKey:"isin"
				title:"Décision"
				text: "<p>Au seuil de 95%, le résultat de l'échantillon permet-il de rejeter l'affirmation $p=#{p}$% ?</p>"
				choix: ["Oui", "Non"]
				good: if isIn then 1 else 0
				correction: if isIn then ["$f = \\frac{#{ne}}{#{n}} \\in I_F$ donc l'affirmation est acceptée au seuil de 95%."] else ["$f = \\frac{#{ne}}{#{n}} \\not\\in I_F$ donc l'affirmation est rejetée au seuil de 95%."]
				aide:[
					"On rejette l'affirmation au seuil de 95% quand $f \\not\\in I_F$, avec $f$ la fréquence d'individus ayant la propriété recherchée dans l'échantillon"
				]
			}
		]
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			out.push {
				title:@title
				content: ennonce + Handlebars.templates["tex_enumerate"] {
					pre:itData.tex.habillage
					items: [
						"Donnez l'intervalle de fluctuation asymptotique à 95\\% de $f$ en arrondissant à 0,001 = 0,1\\% près."
						"Au seuil de 95\\%, doit-on rejeter l'affirmation $p=#{itData.tex.p}\\%$ ?"
					]
					large:slide is true
				}
			}
		out
