
Exercice.liste.push
	id:22
	title:"Développer une expression"
	description:"Une expression est donnée, il faut la développer."
	keyWords:["Algèbre", "fonction"]
	options: {
		a:{ tag:"Difficulté" , options:["Alea", "Facile", "Facile avec fraction", "Moyen", "Moyen avec fraction"] , def:0 }
	}
	init: (data) ->
		if data.inputs.p? then poly = mM.toNumber data.inputs.p
		else
			if data.options.a.value is 0 then a = mM.alea.in [1,2,3]
			else a = data.options.a.value
			switch a
				when 2 then poly = mM.exec [@aleaMult(0,false), @aleaMult(2,true), "+"]
				when 3 then poly = mM.exec [@aleaMult(2,false), @aleaMult(2,false), "+"]
				when 4 then poly = mM.exec [@aleaMult(2,false), @aleaMult(2,true), "+"]
				else poly = mM.exec [@aleaMult(0,false), @aleaMult(2,false), "+"]
			data.inputs.p = String poly
		data.polyTex = polyTex = poly.tex()
		polyDev = data.polyDev = mM.exec [ poly ], { simplify:true, developp:true }
		data.polyDevTex = "P(x)="+polyDev.tex()
		data.liste = []
		if data.answers.Ps?
			# Il faut récupérer toutes les entrées
			l = data.answers.Ps.split(";")
			for it in l
				# On ne s'occupe pas du dernier
				if lastP?
					itp = mM.p.userAnswer lastP, {type:"number", simplify:false}
					data.liste.push "P(x)="+itp.tex
				data.lastP = it
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:"<p>Soit $P(x) = #{polyTex}$</p><p>Donnez la forme développée de $P(x)$. <i>Vous pouvez procéder par étapes.</i></p>"
			}]}
			new Brique {
				data:data
				bareme:100
				needed:["Ps"]
				repeat:true
				ask: ()->
					@container.html Handlebars.templates.std_panel {
						title:"Développer"
						zones:[
							{ list:"liste" }
							{
								body:"form"
								html:Handlebars.templates.std_form {
									id:"form#{@divId}"
									inputs:[{ large:true, tag:"$P(x) = $", name:"P" }]
									clavier:[{name:"sqr-button", title:"Carré", tag:"$\\cdot^2$"}]
								}
							}
						]
					}
					$("#form#{@divId}").on 'submit', (event) =>
						user = $("input[name='P']",@container).val()
						if @a.Ps? then @a.Ps = @a.Ps+";"+user
						else @a.Ps = user
						@run true
						false
					@gc = new GestClavier $("input[name='P']",@container)
					$("button[name='sqr-button']",@container).on 'click', (event) => @gc.clavier("","^2",false)
					$("input[name='P']").focus()
				ver: () ->
					l = @a.Ps.split(";")
					if @data.list?
						l = [ l.pop() ] # On ne traite que le dernier
						onlyLast = true
					else @data.list = []
					for it in l
						itp = mM.p.userAnswer it, {type:"number", simplify:true}
						@data.list.push itp.tex
					# On analyse le dernier
					ecart = @data.polyDev.toClone().am(itp.object,true).simplify()
					correct = ecart.isNul()
					if itp.forme({fraction:true}) or not correct
						# fini
						@config.repeat = false
						if correct
							text = "Bonne réponse."
							@data.note = @bareme
						else text = "<b>Erreur !</b> La bonne réponse était : $#{@data.polyDevTex}$"
						@container.html Handlebars.templates.std_panel {
							title:"Développer"
							zones:[{
								list:"liste"
								html: Handlebars.templates.listItem ({text:"$P(x)=#{it}$"} for it in @data.list).concat([{ color: (if correct then "ok" else "error"), text:text}])
							}]
						}
					else
						# pas fini
						if onlyLast
							$("ul[name='liste']",@container).append Handlebars.templates.listItem [{text:"$P(x)=#{itp.tex}$"}]
						else
							@ask() # On crée le formulaire
							$("ul[name='liste']",@container).append Handlebars.templates.listItem ({text:"$P(x)=#{it}$"} for it in @data.list)
			}
		]
	aleaMult:(degreTotal,fraction)->
		# On cherche à obtenir un produit d'expressions dont le produit dont le degre est degreTotal
		expr_array = []
		if degreTotal is 0 then expr_array.push mM.alea.number({min:1, max:50})
		else
			total = 0
			n = 0
			while total<degreTotal
				# On génère un polynome de degré aléatoire
				new_degre = mM.alea.real { min:1, max:degreTotal-Math.max(total,1) }
				new_poly = mM.alea.poly { degre:new_degre, coeffDom:{min:1, max:10, sign:true}, values:{min:-10, max:10} }
				# On envisage de mettre ce polynome au carré si cela passe :
				if (total+2*new_degre<=degreTotal) and mM.alea.dice(1,3)
					total += new_degre*2
					expr_array.push(new_poly, 2, "^")
				else
					total+=new_degre
					expr_array.push new_poly
				n += 1
				if n>1 then expr_array.push("*")
		if fraction then expr_array.push(mM.alea.number({min:2, max:9}), "/")
		if mM.alea.dice(1,3) then expr_array.push "*-"
		mM.exec expr_array
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:"Développer"
			content:Handlebars.templates["tex_enumerate"] { items: ("$P_{#{i}}(x) = #{item.polyTex}$" for item,i in data), large:false }
		}
