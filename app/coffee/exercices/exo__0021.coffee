
Exercice.liste.push
	id:21
	title:"Médiane et quartiles"
	description:"Une série statistique est donnée. Il faut calculer le premier quartile, la médiane et le troisième quartile."
	keyWords:["Statistiques","Médiane","Quartile","Seconde"]
	init: (data) ->
		if (typeof data.inputs.table is "undefined")
			resolution = mM.alea.real [0.5, 1, 5, 10]
			std = mM.alea.real({ min:100, max:200 })/100*resolution
			moy = mM.alea.real({ min:4, max:10 })*std
			min = quantifyNumber(moy,resolution) - 5*resolution
			max = quantifyNumber(moy,resolution) + 5*resolution
			N = mM.alea.real { min:50, max:200 }
			table = ( mM.alea.real { gaussian:{ moy:moy, std:std, min:min, max:max, delta:resolution } } for i in [1..N] )
			serie = new SerieStat( table )
			serie.countEffectifs()
			data.inputs.table = serie.storeInString()
		else
			serie = new SerieStat(data.inputs.table)
		values = (item.value for item in serie.toStringArray())
		effectifs = (item.effectif for item in serie.toStringArray())
		[
			new BEnonce { zones:[
				{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p>"}
				{table:"table", lignes:[{entete:"$x_i$", items:values},{entete:"$n_i$", items:effectifs}]}
			]}
			new BListe {
				data:data
				bareme:100
				title:"Donnez les indicateurs statistiques de la série"
				liste:[
					{tag:"$N$", name:"N", description:"Effectif total", good:serie.N()}
					{tag:"Médiane", name:"mediane", description:"Médiane (à 0,1 près)", good:serie.mediane(), params:{arrondi:-1}}
					{tag:"$q_1$", name:"q1", description:"Premier quartile (à 0,1 près)", good:serie.fractile(1,4), params:{arrondi:-1}}
					{tag:"$q_3$", name:"q3", description:"Premier quartile (à 0,1 près)", good:serie.fractile(3,4), params:{arrondi:-1}}
				]
				aide: oHelp.stats.N.concat(oHelp.stats.mediane, oHelp.stats.quartiles)
			}
		]
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			serie = new SerieStat itData.inputs.table
			xs = serie.getValues()
			xs.unshift("$x_i$")
			ns = serie.getEffectifs()
			ns.unshift("$n_i$")
			ennonce = Handlebars.templates["tex_tabular"] {
				pre:"On considère la série statistique donnée par le tableau suivant :"
				lines: [xs, ns]
				cols: xs.length
				large: slide is true
			}
			out.push {
				title:@title
				content: ennonce + Handlebars.templates["tex_enumerate"] {
					items: [
						"Donnez l'effectif total $N$"
						"Donnez la médiane de la série, à $0,1$ près"
						"Donnez les premier et troisième quartile, à $0,1$ près"
					]
					large:slide is true
				}
			}
		out
