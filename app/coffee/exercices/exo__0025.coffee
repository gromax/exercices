
Exercice.liste.push
	id:25
	title:"Loi binomiale : Intervalle de fluctuation"
	description:"Calculer un intervalle de fluctuation."
	keyWords:["probabilités","binomiale","Intervalle de fluctuation","Première"]
	options: {
		a:{ tag:"Calcul de E(X) et sigma", options:["non", "oui"], def:0}
	}
	init: (data) ->
		inp = data.inputs
		if (typeof inp.n is "undefined") then inp.n = mM.alea.real {min:20, max:100}
		else inp.n = Number inp.n
		if (typeof inp.p is "undefined") then inp.p = mM.alea.real({min:1, max:19})
		else inp.p = Number inp.p
		{Xlow,Xhigh} = mM.intervalle_fluctuation.binomial(inp.n,inp.p/100)
		if (typeof inp.nf is "undefined") then nf = inp.nf = Math.min Xhigh+mM.alea.real({min:-2, max:2}), inp.n
		else nf = Number inp.nf
		# Tableau pour l'étape 2
		Xdeb = Math.max(Xlow-mM.alea.real({min:1, max:3}),0)
		Xfin = Math.min(Xlow+mM.alea.real({min:1, max:3}),Xhigh)
		Xdeb2 = Math.max(Xhigh-mM.alea.real({min:1, max:3}),Xlow)
		Xfin2 = Math.min(Xhigh+mM.alea.real({min:1, max:3}),inp.n)
		if Xdeb2<=Xfin then k_values = [Xdeb..Xfin2]
		else k_values = [Xdeb..Xfin].concat [Xdeb2..Xfin2]
		p_values = ( numToStr( mM.repartition.binomial(inp.n,inp.p/100,k),3 ) for k in k_values)
		flow=Xlow/inp.n
		fhigh=Xhigh/inp.n
		IF = mM.ensemble.intervalle "[", fixNumber(flow,2), fixNumber(fhigh,2), "]"
		data.tex = {
			p:inp.p
			n:inp.n
			nf:nf
		}
		out = [
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>Une usine fabrique des tuyaux en caoutchouc. Le fabriquant affirme que #{inp.p}% des tuyaux sont poreux. On prélève #{inp.n} tuyaux dans la production et on obtient #{nf} tuyaux poreux.</p>"
				}
				{
					well:"schema"
					html:"<ul><li><b>Épreuve élémentaire :</b> Prélever un tuyau.</li><li><b>Succès :</b> Le tuyau est poreux.</li><li><b>Probabilité du succès :</b> $p=#{inp.p}$%</li><li>L'expérience est répétée $n=#{inp.n}$ fois de façon indépendante (production assez importante). $X$ est le nombre de succès (tuyaux poreux). On peut donc dire que $X$ suit une loi binomiale $\\mathcal{B}(#{inp.n} ; #{numToStr inp.p/100, 2})$.</li></ul>"
				}
			]}
		]
		if data.options.a.value is 1 then out.push new BListe {
			data:data
			bareme:40
			title:"Espérance et écart-type"
			liste:[
				{
					tag:"$E(X)=$"
					name:"esp"
					description:"Espérance à 0,01 près"
					good:inp.n*inp.p/100
					arrondi:-2
				}
				{
					tag:"$\\sigma(X)$"
					name:"std"
					description:"Écart-type à 0,001 près"
					good:Math.sqrt(inp.n*inp.p*(100-inp.p))/100
					arrondi:-2
				}
			]
			aide: [
				"L'espérance est la valeur attendue. Si on a un fréquence $p$ de tuyaux poreux dans la production, si on prélève $n$ tuyaux, on s'attend à obtenir $E(X)=n\\times p$ tuyaux poreux."
				"Naturellement, le nombre de tuyau réellement obtenu dans un prélèvement va varier aléatoirement. Pour un résultat donné, pour savoir s'il est loin ou proche de la valeur attendue, on utilise l'écart-type qui se cacule : $\\sigma(X)=\\sqrt{np(1-p)}$. Jusqu'à $2\\sigma$, on est assez proche de la valeur espérée. Au-delà de $2\\sigma$, on est loin."
			]
		}
		out.push new BListe {
			data:data
			bareme:60
			title:"Intervalle de fluctuation"
			liste:[
				{
					tag:"$a$"
					name:"a"
					description:"Nombre entier"
					good:Xlow
				}
				{
					tag:"$b$"
					name:"b"
					description:"Nombre entier"
					good:Xhigh
				}
				{
					tag:"$I_F$"
					name:"IF"
					description:"Intervalle de fluctuation à 0,01 près"
					good:IF
					tolerance:0.005
				}
			]
			text: [
				{
					body:"texte"
					html:"<p>On cherche les bornes de l'intervalle de fluctuation. Pour cela on va chercher $a$, c'est à dire la valeur de $k$ pour laquelle $P(X\\leqslant k)$ dépasse strictement $0,025=2,5\\%$, et $b$, c'est à dire la valeur de $k$ pour laquelle $P(X\\leqslant k)$ dépasse ou atteint $0,975=97,5\\%$. On sait que $a$ doit être proche de $E(X)-2\\sigma(X)$ et que $b$ doit être proche de $E(X)+2\\sigma(X)$.</p><p>On donne le tableau suivant (pour faire gagner du temps car les valeurs du tableau peuvent être obtenues avec une calculatrice)</p>"
				}
				{
					table:"calculette"
					lignes:[
						{ entete:"$k$", items:k_values }
						{ entete:"$p(X\\leqslant k)$", items:p_values }
					]
				}
			]
			aide:oHelp.proba.binomiale.IF_1
		}
		accepter = (nf>=Xlow) and (nf<=Xhigh)
		out.push new BChoixMultiple {
			data:data
			bareme:20
			aKey:"d"
			title:"Décision"
			choix: ["Accepter", "Rejeter"]
			good: if accepter then 0 else 1
			correction: if accepter then ["$f=\\frac{#{nf}}{#{inp.n}}\\in I_F$ donc l'affirmation est acceptée au risque de 5%"] else ["$f=\\frac{#{nf}}{#{inp.n}}\\not\\in I_F$ donc l'affirmation est rejetée au risque de 5%"]
			aide:["Il faut calculer $f$, la fréquence de tuyaux poreux dans l'échantillon. Ensuite, on accepte si $f\\in I_F$."]
		}
		out
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out=[]
		for itemData in data
			items = [
				"Donnez l'intervalle de fluctuation à 95\\%."
				"Doit-on accepter l'affirmation du fabriquant ?"
			]
			if itemData.options.a.value is 1 then items.unshift "$X$ le nombre de tuyaux poreux suit $\\mathcal{B}(#{itemData.tex.n};#{itemData.tex.p}\\%)$. Donnez $E(X)$ et $\\sigma(X)$."
			out.push {
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre: "Une usine fabrique des tuyaux en caoutchouc. Le fabriquant affirme que #{itemData.tex.p}\\% des tuyaux sont poreux. On prélève #{itemData.tex.n} tuyaux dans la production et on obtient #{itemData.tex.nf} tuyaux poreux."
					items: items
				}
			}
		out
