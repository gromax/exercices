
Exercice.liste.push
	id:21
	title:"Médiane et quartiles"
	description:"Une série statistique est donnée. Il faut calculer le premier quartile, la médiane et le troisième quartile."
	keyWords:["Statistiques","Médiane","Quartile","Seconde"]
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
				{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p>"}
				{table:"table", lignes:[{entete:"$x_i$", items:values},{entete:"$n_i$", items:effectifs}]}
			]}
			new BListe {
				data:data
				bareme:100
				title:"Donnez les indicateurs statistiques de la série"
				liste:[{tag:"$N$", name:"N", description:"Effectif total", good:stat.N()}, {tag:"Médiane", name:"mediane", description:"Médiane (à 0,1 près)", good:stat.mediane(), params:{arrondi:-1}}, {tag:"$q_1$", name:"q1", description:"Premier quartile (à 0,1 près)", good:stat.fractile(1,4), params:{arrondi:-1}}, {tag:"$q_3$", name:"q3", description:"Premier quartile (à 0,1 près)", good:stat.fractile(3,4), params:{arrondi:-1}}]
				aide: oHelp.stats.N.concat(oHelp.stats.mediane, oHelp.stats.quartiles)
			}
		]
