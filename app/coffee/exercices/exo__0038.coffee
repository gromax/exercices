
Exercice.liste.push
	id:38
	title: "Choix de la meilleure forme"
	description: "Une fonction du second degré est donnée sous différentes formes. Vous devez utiliser la plus appropriée meilleure pour répondre à différentes questions."
	keyWords:["Analyse", "Second degré", "Seconde"]
	init: (data) ->
		inp = data.inputs
		# On définit le polynome par ses racines et a
		if inp.a? then a=Number inp.a
		else a=inp.a=Proba.aleaEntreBornes(1,5,true)
		if inp.x1? then x1=Number inp.x1
		else x1=inp.x1=Proba.aleaEntreBornes(-10,10)
		if inp.x2? then x2=Number inp.x2
		else x2=inp.x2=Proba.aleaEntreBornes(-10,10)
		if inp.A? then A=Number inp.A # Pour résoudre f(x)=A
		else A=inp.A=Proba.aleaIn([1,3,9,16,25])*Proba.aleaSign()
		# on veut x1 != x2
		x2=inp.x2=Proba.aleaEntreBornes(-50,50) while x2 is x1
		poly = Polynome.generate_width_roots(a,[x1,x2],"x")
		# Les trois formes
		normalTex = poly.tex()
		canoniqueTex = poly.tex({canonique:true})
		factoTex = NumberManager.makeNumber("#{a}*(x-#{x1})*(x-#{x2})").tex()
		a = NumberManager.makeNumber(a)
		sol1 = NumberManager.makeNumber(x1)
		sol2 = NumberManager.makeNumber(x2)
		xS = sol1.toClone().am(sol2,false).md(NumberManager.makeNumber(2),true)
		yS = poly.calc xS
		A = NumberManager.makeNumber(A).md(a,false).am(yS,false).simplify()
		if A.isNul() then A=poly.calc(Proba.aleaEntreBornes(11,15))
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:"<p>On propose la fonction $f$ définie par : $f(x)=#{normalTex}$.</p><p>La forme canonique est $f(x)=#{canoniqueTex}$.</p><p>La forme factorisée est $f(x)=#{factoTex}$.</p><p>En utilisant bien ces différentes formes, les deux premières questions ne nécessitent aucun calcul.</p>"
			}]}
			new Brique {
				data:data
				bareme:30
				needed:["xS","yS"]
				good:[xS,yS]
				ask:()->
					@container.html Handlebars.templates.std_panel {
						title:"Coordonnées de $S$, sommet de la courbe de $f$."
						zones:[
							{
								body:"champ"
								html:Handlebars.templates.std_form {
									id:"form#{@divId}"
									inputs:[
										{tag:"$x_S$", description:"Abscisse de S", name:"xS"}
										{tag:"$y_S$", description:"Ordonnée de S", name:"yS"}
									]
								}
							}
						]
					}
					$("#form#{@divId}").on 'submit', (event) =>
						@a.xS = $("input[name='xS']",@container).val()
						@a.yS = $("input[name='yS']",@container).val()
						@run true
						false
					$("input[name='xS']",@container).focus()
				ver:()->
					values = [ @verification("xS","$x_S$", @a.xS, @config.good[0],@bareme/2), @verification("yS","$y_S$", @a.yS, @config.good[1],@bareme/2) ]
					@container.html Handlebars.templates.verif {values:values, title:"Coordonnées : $S\\left(#{@config.good[0].tex()};#{@config.good[1].tex()}\\right)$"}
			}
			new BSolutions {
				data:data
				bareme:30
				aKey:"racines"
				title:"Solutions de $f(x)=0$"
				solutions:[sol1,sol2]
			}
			new BSolutions {
				data:data
				bareme:40
				aKey:"sols"
				touches:["sqrt"]
				title:"Solutions de $f(x)=#{A.tex()}$"
				solutions:poly.solveExact(A,false)
			}
		]
