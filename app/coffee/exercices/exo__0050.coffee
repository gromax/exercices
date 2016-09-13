
Exercice.liste.push
	id:50
	title:"Ajustement par la méthode des moindres carrés"
	description:"On vous donne une série statistique à deux variables $(x;y)$. Vous devez déterminer un ajustement de $y$ en $x$ par la méthode des moindres carrés."
	keyWords:["Statistiques","Ajustement","carré","TSTL","BTS"]
	init: (data) ->
		if (typeof data.inputs.table is "undefined")
			N = Proba.aleaEntreBornes(7,11)
			{min,max,ecart} = Proba.aleaIn [ {min:1, max:10, ecart:3}, {min:100, max:500, ecart:100}, {min:1000, max:9000, ecart:1000} ]
			table_x = (Proba.aleaEntreBornes(min,max) for i in [1..N])
			_a = Math.random()*2
			_b = Math.random()*(min+max)/2
			table_y = ((_a*x+_b).round(0) for x in table_x)
			serie_x = new SerieStat table_x
			serie_y = new SerieStat table_y
			data.inputs.table = serie_x.storeInString()+"_"+serie_y.storeInString()
		else
			tables = data.inputs.table.split("_")
			serie_x = new SerieStat tables[0]
			serie_y = new SerieStat tables[1]
		{ a, b, r } = serie_x.ajustement serie_y
		console.log "sx : sum_x = "+serie_x.sum()+" sum_xx = "+ serie_x.sum_sq()+" moyenne = "+ serie_x.moyenne()+" variance = "+serie_x.variance()+" c_xy = "+serie_x.covariance(serie_y)+" sum_xy = "+serie_x.sum_xy(serie_y)
		console.log a
		console.log b
		[
			new BEnonce { zones:[
				{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p>"}
				{table:"table", lignes:[{entete:"$x_i$", items:serie_x.getValues()},{entete:"$y_i$", items:serie_y.getValues()}]}
			]}
			new BListe {
				data:data
				bareme:100
				title:"Donnez les coefficients de l'ajustement affine : $y=ax+b$ à 0,01 près"
				liste:[
					{tag:"$a$", name:"a", description:"(à 0,01 près)", good:a, params:{arrondi:-2}}
					{tag:"$b$", name:"b", description:"(à 0,1 près)", good:b, params:{arrondi:-2}}
				]
				aide:oHelp.stats.ajustement.concat(oHelp.stats.variance,oHelp.stats.covariance)
			}
		]
