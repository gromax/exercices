
Exercice.liste.push
	id:50
	title:"Ajustement par la méthode des moindres carrés"
	description:"On vous donne une série statistique à deux variables $(x;y)$. Vous devez déterminer un ajustement de $y$ en $x$ par la méthode des moindres carrés."
	keyWords:["Statistiques","Ajustement","carré","TSTL","BTS"]
	options: {
		a:{ tag:"Coordonnées du point moyen" , options:["Non", "Oui"] , def:0 }
		b:{ tag:"Changement de variable" , options:["Non", "Oui"] , def:0 }
		c:{ tag:"Calcul d'interpolation" , options:["Non", "Oui"] , def:0 }
	}
	init: (data) ->
		calculG = data.options.a.value is 1
		calculInterpolation = data.options.c.value is 1
		totalBareme = 100 # Pour l'ajustement
		if calculG then totalBareme += 50
		if calculInterpolation then totalBareme += 50
		if typeof data.inputs.cv isnt "undefined" then cv = Number data.inputs.cv
		else
			if data.options.b.value is 0 then cv = data.inputs.cv = 0
			else cv = data.inputs.cv = mM.alea.real [1,2,3]
			# Les changements de variables sont : ln ; ln(A-y) ; ln(A/y-b)
		if (typeof data.inputs.table is "undefined")
			N = mM.alea.real { min:7, max:11 }
			ecart = mM.alea.real [1,2,4,5,10]
			min = mM.alea.real([0,1,2,3,4,5])*ecart
			max = (N-1)*ecart+min
			table_x = ( i*ecart+min for i in [0..N])
			serie_x = new SerieStat table_x
			# Si on a un changement de variable, il faudra faire un e^z
			# et donc que le e^z n'ait pas une trop grande amplitude. Disons 4.
			switch cv
				when 1 # y = exp(ax+b)
					_a = 2*(1+Math.random())/(max-min)
					_b = 1+Math.random()*4-_a*min
					table_y = ( fixNumber(Math.exp(_a*x+_b),0) for x in table_x)
				when 2 # y = A/(1+exp(ax+b)), a négatif et pour min, il faut qu'en min, ax+b proche de 2 ou 3
					A = mM.alea.real {min:200, max:800}
					data.inputs.A = String A
					_a = -2*(1+Math.random())/(max-min)
					_b = 2+Math.random()-_a*min
					table_y = ( fixNumber(A/(1+Math.exp(_a*x+_b)),0) for x in table_x)
				when 3 # y = A - exp(ax+b) - Il faut exp(b) proche de A
					A = mM.alea.real {min:200, max:500}
					data.inputs.A = String A
					_a = -2*(1+Math.random())/(max-min)
					_b = Math.log(A)-Math.random()-_a*min
					table_y = ( fixNumber(A-Math.exp(_a*x+_b),0) for x in table_x)
				else
					_a = 1.1+Math.random()*10/ecart
					_b = Math.random()*(min+max)/2
					table_y = ( fixNumber(_a*x+_b,0) for x in table_x)
			serie_y = new SerieStat table_y
			data.inputs.table = serie_x.storeInString()+"_"+serie_y.storeInString()
		else
			tables = data.inputs.table.split("_")
			serie_x = new SerieStat tables[0]
			serie_y = new SerieStat tables[1]
			if (cv is 2) or (cv is 3) then A = Number data.inputs.A
		# Calcul des bonnes valeurs de a et b tenant compte des fixNumber qui créent une variation
		switch cv
			when 1
				serie_z = serie_y.transform (x)->Math.log(x)
				chgTex = "$z = \\ln(y)$"
			when 2
				serie_z = serie_y.transform (x)->Math.log(A/x-1)
				chgTex = "$z = \\ln\\left(\\dfrac{#{A}}{y}-1\\right)$"
			when 3
				serie_z = serie_y.transform (x)->Math.log(A-x)
				chgTex = "$z = \\ln(#{A}-y)$"
			else serie_z = serie_y
		{ a, b, r } = serie_x.ajustement serie_z, 3
		if cv is 0
			out = [
				new BEnonce { zones:[
					{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p>"}
					{table:"table", lignes:[{entete:"$x_i$", items:serie_x.getValues()},{entete:"$y_i$", items:serie_y.getValues()}]}
				]}
			]
		else
			out = [
				new BEnonce { zones:[
					{body:"enonce", html:"<p>On considère la série statistique donnée par le tableau suivant :</p>"}
					{table:"table", lignes:[{entete:"$x_i$", items:serie_x.getValues()},{entete:"$y_i$", items:serie_y.getValues()}]}
					{body:"enonce_suite", html:"<p>On propose le changement de variable suivant : #{chgTex}.</p>"}
				]}
			]
		if cv is 0 then tagVar = "y" else tagVar = "z"

		if calculG
			out.push(
				new BListe {
					data:data
					bareme:Math.round(50/totalBareme*100)
					title:"Donnez les coordonnées de $G$, le point moyen du nuage des $M_i\\left(x_i;#{tagVar}_i\\right)$ à 0,01 près"
					liste:[
						{tag:"$x_G$", name:"xG", description:"à 0,01 près", good:serie_x.moyenne(), params:{arrondi:-2}}
						{tag:"$#{tagVar}_G$", name:"yG", description:"à 0,01 près", good:serie_z.moyenne(), params:{arrondi:-2}}
					]
					aide:oHelp.stats.centre
				}
			)
		out.push(
			new BListe {
				data:data
				bareme:Math.round(100/totalBareme*100)
				title:"Donnez les coefficients de l'ajustement affine : $#{tagVar}=ax+b$ à 0,001 près"
				liste:[
					{tag:"$a$", name:"a", description:"à 0,001 près", good:a, params:{arrondi:-3}}
					{tag:"$b$", name:"b", description:"à 0,001 près", good:b, params:{arrondi:-3}}
				]
				aide:oHelp.stats.ajustement.concat(oHelp.stats.variance,oHelp.stats.covariance)
			}
		)

		if calculInterpolation
			if typeof data.inputs.i is "undefined"
				i = data.inputs.i = min + Math.floor( ecart*10*(mM.alea.real([1..N-2])+.2+Math.random()*.6) )/10
			else i = Number data.inputs.i
			switch cv
				when 1 then y = Math.exp(a*i+b)
				when 2 then y = A/(1+Math.exp(a*i+b))
				when 3 then y = A - Math.exp(a*i+b)
				else y = a*i+b
			out.push(
				new BListe {
					data:data
					bareme:Math.round(50/totalBareme*100)
					title:"Donnez la valeur de $y$ pour $x = #{numToStr(i,1)}$ à 0,01 près"
					liste:[
						{tag:"$y$", name:"y", description:"(à 0,01 près)", good:y, params:{arrondi:-2}}
					]
				}
			)
		out
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			cv = Number itData.inputs.cv
			tables = itData.inputs.table.split("_")
			xs = tables[0].split(";")
			ys = tables[1].split(";")
			xs.unshift("$x_i$")
			ys.unshift("$y_i$")
			ennonce = Handlebars.templates["tex_tabular"] {
				pre:"On considère la série statistique donnée par le tableau suivant :"
				lines: [xs, ys]
				cols: xs.length
				large: slide is true
			}
			switch cv
				when 1 then tex_chgt = "On propose le changement de variable suivant : $z = \\ln(y)$."
				when 2
					A = Number itData.inputs.A
					tex_chgt = "On propose le changement de variable suivant : $z = \\ln\\left(\\dfrac{#{A}}{y}-1\\right)$."
				when 3
					A = Number itData.inputs.A
					tex_chgt = "On propose le changement de variable suivant : $z = \\ln(#{A}-y)$."
				else tex_chgt = ""
			if cv is 0 then tagVar = "y" else tagVar = "z"
			its=[]
			if itData.options.a.value isnt 0
				its.push "Donnez les coordonnées de $G$, centre du nuage des $M_i\\left(x_i;#{tagVar}_i\\right)$ à $0,01$ près."
			its.push "Donnez les coefficients de l'ajustement affine : $#{tagVar}=ax+b$ à 0,001 près"
			if itData.options.c.value isnt 0
				i = Number itData.inputs.i
				its.push "Donnez la valeur de $y$ pour $x = #{numToStr(i,1)}$ à 0,01 près"
			out.push {
				title:@title
				content: ennonce + Handlebars.templates["tex_enumerate"] {
					pre:tex_chgt
					items: its
					large:slide is true
				}
			}
		out

