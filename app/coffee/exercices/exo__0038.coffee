
Exercice.liste.push
	id:38
	title: "Choix de la meilleure forme"
	description: "Une fonction du second degré est donnée sous différentes formes. Vous devez utiliser la plus appropriée meilleure pour répondre à différentes questions."
	keyWords:["Analyse", "Second degré", "Seconde"]
	init: (data) ->
		inp = data.inputs
		# On définit le polynome par ses racines et a
		if inp.a? then a = mM.toNumber inp.a
		else
			a = mM.alea.number { min:1, max:5, sign:true }
			inp.a = String a
		if inp.x1? then x1 = mM.toNumber inp.x1
		else
			x1= mM.alea.number { min:-10, max:10 }
			inp.x1 = String x1
		if inp.x2? then x2 = mM.toNumber inp.x2
		else
			x2 = mM.alea.number { min:-10, max:10, no:[Number inp.x1]}
			inp.x2 = String x2
		if inp.A? then A = mM.toNumber inp.A # Pour résoudre f(x)=A
		else
			A = mM.alea.number { values:[1,3,9,16,25], sign:true }
			inp.A = String A
		poly = mM.exec [a, "x", x1, "-", "x", x2, "-", "*", "*"]
		factoTex = poly.tex()
		poly = poly.toPolynome("x")
		# Les trois formes
		normalTex = poly.tex()
		canoniqueTex = poly.tex({canonique:true})
		factoTex = mM.exec([a, "x", x1, "-", "x", x2, "-", "*", "*"]).tex()
		xS = mM.exec [x1, x2, "+", 2, "/"], {simplify:true}
		yS = poly.calc xS
		A = mM.exec [A, a, "*", yS, "+"], { simplify: true }
		if A.isNul() then A=poly.calc( mM.alea.real { min:11, max:15 } )
		data.exam = { normale:normalTex, canonique:canoniqueTex, facto:factoTex, A:A.tex() }
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:"<p>On propose la fonction $f$ définie par : $f(x)=#{normalTex}$.</p><p>La forme canonique est $f(x)=#{canoniqueTex}$.</p><p>La forme factorisée est $f(x)=#{factoTex}$.</p><p>En utilisant bien ces différentes formes, les deux premières questions ne nécessitent aucun calcul.</p>"
			}]}
			new BListe {
				title:"Coordonnées de $S$, sommet de la courbe de $f$."
				data:data
				bareme:30
				liste:[
					{
						name:"xS"
						good:xS
						tag:"$x_S$"
						description:"Abscisse de S"
					}
					{
						name:"yS"
						good:yS
						tag:"$y_S$"
						description:"Ordonnée de S"
					}
				]
			}
			new BListe {
				data:data
				bareme:30
				title:"Solutions de $f(x)=0$"
				touches:["empty"]
				liste:[{
					name:"racines"
					tag:"$\\mathcal{S}$"
					large:true
					solutions:[x1,x2]
				}]
			}
			new BListe {
				data:data
				bareme:40
				touches:["empty","sqrt"]
				title:"Solutions de $f(x)=#{A.tex()}$"
				liste:[{
					name:"sols"
					tag:"$\\mathcal{S}$"
					large:true
					solutions: mM.polynome.solve.exact poly, { y:A }
				}]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itemData in data
			out.push {
				title:"Choix de la meilleure forme"
				contents: [
					"On donne $f(x)$ sous trois formes :"
					"\\[f(x) = #{itemData.exam.normale}\\]"
					"\\[f(x) = #{itemData.exam.canonique}\\]"
					"\\[f(x) = #{itemData.exam.facto}\\]"

					Handlebars.templates["tex_enumerate"] { pre:"Sans, ou avec peu de calcul, en utilisant la forme la plus adaptée, donnez :", items:[
						"Les coordonnées du sommet $S$ de la courbe de $f$"
						"Les solutions de $f(x) = 0$"
						"Les solultions, si elles existent, de $f(x) = #{itemData.exam.A}$"
						]}
				]
			}
		out
