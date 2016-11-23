
Exercice.liste.push
	id:20
	title:"Moyenne et écart-type"
	description:"Une série statistique est donnée. Il faut calculer sa moyenne et son écart-type."
	keyWords:["Statistiques","Moyenne","Écart-type","Première"]
	init: (data) ->
		if (typeof data.inputs.table is "undefined")
			resolution = mM.alea.real [0.5, 1, 5, 10]
			std = mM.alea.real({min:100, max:200})/100*resolution
			moy = mM.alea.real({min:4, max:10})*std
			min = quantifyNumber(moy,resolution) - 5*resolution
			max = quantifyNumber(moy,resolution) + 5*resolution
			N = mM.alea.real({min:50, max:200})
			table = ( mM.alea.real { gaussian: { moy:moy, std:std, min:min, max:max, delta:resolution} } for i in [1..N] )
			serie = new SerieStat( table )
			serie.countEffectifs()
			data.inputs.table = serie.storeInString()
		else
			serie = new SerieStat(data.inputs.table)
		values = (item.value for item in serie.toStringArray())
		effectifs = (item.effectif for item in serie.toStringArray())
		[
			new BEnonce { zones:[
				{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p><p><i>Les $x_i$ sont les valeurs et les $n_i$ sont les effectifs</i></p>"}
				{table:"table", lignes:[{entete:"$x_i$", items:values},{entete:"$n_i$", items:effectifs}]}
			]}
			new BListe {
				data:data
				bareme:100
				title:"Donnez les indicateurs statistiques de la série"
				liste:[
					{tag:"$N$", name:"N", description:"Effectif total", good:serie.N()}
					{tag:"$\\overline{x}$", name:"m", description:"Moyenne (à 0,1 près)", good:serie.moyenne(), params:{arrondi:-1}}
					{tag:"$\\sigma$", name:"std", description:"Écart-type (à 0,1 près)", good:serie.std(), params:{arrondi:-1}}
				]
				aide:oHelp.stats.N.concat(oHelp.stats.moyenne,oHelp.stats.ecart_type)
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
						"Donnez la moyenne $\\overline{x}$ de la série, à $0,1$ près"
						"Donnée l'écart-type $\\sigma$ à $0,1$ près"
					]
					large:slide is true
				}
			}
		out
