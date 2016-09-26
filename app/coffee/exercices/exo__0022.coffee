
Exercice.liste.push
	id:22
	title:"Développer une expression"
	description:"Une expression est donnée, il faut la développer."
	keyWords:["Algèbre", "fonction"]
	init: (data) ->
		# Debug_old_version
		if data.inputs.poly?
			data.inputs.p = data.inputs.poly
			data.inputs.poly = undefined
		if data.answers.P?
			data.answers.Ps = data.answers.P
			data.answers.P = undefined
		# Fin Debug
		if data.inputs.p? then poly = NumberManager.makeNumber data.inputs.p
		else
			poly = NumberManager.makeSum([@aleaMult(0),@aleaMult(2)])
			data.inputs.p = String poly
		data.polyTex = polyTex = poly.tex()
		polyObj = poly.toPolynome()
		data.polyDev = polyObj.toNumberObject()
		data.polyDevTex = "P(x)="+polyObj.tex()
		data.liste = []
		if data.answers.Ps?
			# Il faut récupérer toutes les entrées
			l = data.answers.Ps.split(";")
			for it in l
				# On ne s'occupe pas du dernier
				if lastP?
					itp = new Parser lastP, {type:"number", simplify:false}
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
						itp = new Parser it, {type:"number", simplify:true}
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
	aleaMult:(degreTotal)->
		# On cherche à obtenir un produit d'expressions dont le produit dont le degre est degreTotal
		if degreTotal is 0 then output = NumberManager.makeNumber Proba.aleaEntreBornes(1,50)
		else
			total = 0
			expr_array = []
			while total<degreTotal
				# On génère un polynome de degré aléatoire
				new_degre = Proba.aleaEntreBornes(1,degreTotal-Math.max(total,1))
				new_poly = NumberManager.aleaPoly new_degre
				# On envisage de mettre ce polynome au carré si cela passe :
				if (total+2*new_degre<=degreTotal) and (Proba.aleaEntreBornes(1,3) is 3)
					total += new_degre*2
					expr_array.push new_poly.pow(2)
				else
					total+=new_degre
					expr_array.push new_poly
			output = NumberManager.makeProduct expr_array
		if Proba.aleaEntreBornes(1,3) is 3 then output.opposite()
		output
	slide: (data) ->
		if not Tools.typeIsArray(data) then data = [ data ]
		out = ""
		for itemData,i in data
			out += "\\item $P_{#{i}}(x) = #{itemData.polyTex}$"
		out = "
			\\section{Développer}
			\\begin{frame}
			\\myFrameTitle
			\\begin{enumerate}[a)] "+out+" \\end{enumerate}
			\\end{frame}
		"
		out

