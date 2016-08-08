
Exercice.liste.push
	id:20
	title:"Moyenne et écart-type"
	description:"Une série statistique est donnée. Il faut calculer sa moyenne et son écart-type."
	keyWords:["Statistiques","Moyenne","Écart-type","Première"]
	init: (data) ->
		if (typeof data.inputs.table is "undefined")
			resolution = Proba.aleaIn([0.5, 1, 5, 10])
			std = Proba.aleaEntreBornes(100,200)/100*resolution
			moy = Proba.aleaEntreBornes(4,10)*std
			min = moy.toResolution(resolution) - 5*resolution
			max = moy.toResolution(resolution) + 5*resolution
			N = Proba.aleaEntreBornes(50,200)
			table = (Proba.gaussianAlea(moy,std,{min:min, max:max, delta:resolution}) for i in [1..N])
			stat = new Stats( table )
			stat.countEffectifs()
			data.inputs.table = stat.storeInString()
		else
			stat = new Stats(data.inputs.table)
		values = (item.value for item in stat.toStr())
		effectifs = (item.effectif for item in stat.toStr())
		[
			new BEnonce { zones:[
				{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p><p><i>Les $x_i$ sont les valeurs et les $n_i$ sont les effectifs</i></p>"}
				{table:"table", lignes:[{entete:"$x_i$", items:values},{entete:"$n_i$", items:effectifs}]}
			]}
			new BListe {
				data:data
				bareme:100
				title:"Donnez les indicateurs statistiques de la série"
				liste:[{tag:"$N$", name:"N", description:"Effectif total", good:stat.N()}, {tag:"$\\overline{x}$", name:"m", description:"Moyenne (à 0,1 près)", good:stat.moyenne(), params:{arrondi:-1}}, {tag:"$\\sigma$", name:"std", description:"Écart-type (à 0,1 près)", good:stat.std(), params:{arrondi:-1}}]
				aide:oHelp.stats.N.concat(oHelp.stats.moyenne,oHelp.stats.ecart_type)
			}
		]
