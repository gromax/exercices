
Exercice.liste.push
	id:25
	title:"Loi binomiale : Intervalle de fluctuation"
	description:"Calculer un intervalle de fluctuation."
	keyWords:["probabilités","binomiale","Intervalle de fluctuation","Première"]
	init: (data) ->
		inp = data.inputs
		h_init("n",inp,20,100)
		if (typeof inp.p is "undefined") then inp.p = mM.alea.real({min:1, max:19})/100
		else inp.p = Number inp.p
		# Tableau pour l'étape 2
		{Xlow,Xhigh} = mM.intervalle_fluctuation.binomial(inp.n,inp.p)
		Xdeb = Math.max(Xlow-mM.alea.real({min:1, max:3}),0)
		Xfin = Math.min(Xlow+mM.alea.real({min:1, max:3}),Xhigh)
		Xdeb2 = Math.max(Xhigh-mM.alea.real({min:1, max:3}),Xlow)
		Xfin2 = Math.min(Xhigh+mM.alea.real({min:1, max:3}),inp.n)
		if Xdeb2<=Xfin then k_values = [Xdeb..Xfin2]
		else k_values = [Xdeb..Xfin].concat [Xdeb2..Xfin2]
		p_values = ( numToStr( mM.repartition.binomial(k,{n:inp.n, p:inp.p}),3 ) for k in k_values)
		flow=Xlow/inp.n
		fhigh=Xhigh/inp.n
		IF = mM.ensemble.intervalle "[", fixNumber(flow,2), fixNumber(fhigh,2), "]"
		[
			new BEnonce { zones:[
				{
					body:"enonce"
					html:"<p>Une usine fabrique des tuyaux en caoutchouc. On sait que #{inp.p*100}% des tuyaux sont poreux. On prélève #{inp.n} tuyaux dans la production qui est considérée comme assez importante pour qu'on puisse assimiler ce prélèvement à un prélèvement avec remise. On note $X$ le nombre de tuyaux poreux.</p><p>On reconnaît un <b>schéma de Bernoulli</b>.</p>"
				}
				{
					well:"schema"
					html:"<ul><li><b>Épreuve élémentaire :</b> Prélever un tuyau.</li><li><b>Succès :</b> Le tuyau est poreux.</li><li><b>Probabilité du succès :</b> $p=#{numToStr inp.p, 2}$</li><li>L'expérience est répétée $n=#{inp.n}$ fois de façon indépendante (production assez importante). $X$ est le nombre de succès (tuyaux poreux). On peut donc dire que $X$ suit une loi binomiale $\\mathcal{B}(#{inp.n} ; #{numToStr inp.p, 2})$.</li></ul>"
				}
			]}
			new BListe {
				data:data
				bareme:40
				title:"Espérance et écart-type"
				liste:[{tag:"$E(X)=$", name:"esp", description:"Espérance à 0,01 près", good:inp.n*inp.p, params:{arrondi:-2}}, {tag:"$\\sigma(X)$", name:"std", description:"Écart-type à 0,001 près", good:Math.sqrt(inp.n*inp.p*(1-inp.p)), params:{arrondi:-2}}]
				aide: [
					"L'espérance est la valeur attendue. Si on a un fréquence $p$ de tuyaux poreux dans la production, si on prélève $n$ tuyaux, on s'attend à obtenir $E(X)=n\\times p$ tuyaux poreux."
					"Naturellement, le nombre de tuyau réellement obtenu dans un prélèvement va varier aléatoirement. Pour un résultat donné, pour savoir s'il est loin ou proche de la valeur attendue, on utilise l'écart-type qui se cacule : $\\sigma(X)=\\sqrt{np(1-p)}$. Jusqu'à $2\\sigma$, on est assez proche de la valeur espérée. Au-delà de $2\\sigma$, on est loin."
				]
			}
			new BListe {
				data:data
				bareme:60
				title:"Intervalle de fluctuation"
				liste:[{tag:"$a$", name:"a", description:"Nombre entier", good:Xlow}, {tag:"$b$", name:"b", description:"Nombre entier", good:Xhigh}, {tag:"$I_F$", name:"IF", description:"Intervalle de fluctuation à 0,01 près", good:IF, params:{tolerance:0.005}}]
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
		]
