
Exercice.liste.push
	id:38
	title: "Choix de la meilleure forme"
	description: "Une fonction du second degré est donnée sous différentes formes. Vous devez utiliser la plus appropriée meilleure pour répondre à différentes questions."
	keyWords:["Analyse", "Second degré", "Seconde"]
	init: (data) ->
		inp = data.inputs
		# On définit le polynome par ses racines et a
		if inp.a? then a = mM.toNumber inp.a
		else inp.a = String(a = mM.alea.number { min:1, max:5, sign:true })
		if inp.x1? then x1 = Number inp.x1
		else inp.x1 = String(x1= mM.alea.real { min:-10, max:10 })
		if inp.x2? then x2 = Number inp.x2
		else inp.x2 = String(x2 = mM.alea.real { min:-10, max:10, no:[x1]})
		if inp.xA? then xA = Number inp.xA # Pour résoudre f(x)=f(xA)
		else inp.xA = String( xA = mM.alea.real { min:-20, max:20, no:[x1, x2]} )
		polyFacto = mM.exec [a, "x", x1, "-", "x", x2, "-", "*", "*"], { simplify:true }
		xS = mM.exec [x1, x2, "+", 2, "/"], {simplify:true}
		yS = mM.exec [a, xS, x1, "-", xS, x2, "-", "*", "*"], { simplify:true }
		polyCanonique = mM.exec [ a, "x", xS, "-", 2, "^", "*", yS, "+"], { simplify:true }
		factoTex = polyFacto.tex()
		canoniqueTex = polyCanonique.tex()
		poly = mM.exec [ polyFacto ], {simplify:true, developp:true }
		normalTex = poly.tex()
		yA = mM.exec [a, xA, xS, "-", 2, "^", "*", yS, "+"], { developp:true, simplify:true }
		if xA is (x1+x2)/2 then solutionsA = [ mM.toNumber(xA) ]
		else solutionsA = [ mM.toNumber(xA), mM.toNumber(x1+x2-xA) ]
		data.tex = { normale:normalTex, canonique:canoniqueTex, facto:factoTex, yA:yA }
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
				title:"Solutions de $f(x)=#{yA.tex()}$"
				liste:[{
					name:"sols"
					tag:"$\\mathcal{S}$"
					large:true
					solutions: solutionsA
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
					"\\[f(x) = #{itemData.tex.normale}\\]"
					"\\[f(x) = #{itemData.tex.canonique}\\]"
					"\\[f(x) = #{itemData.tex.facto}\\]"

					Handlebars.templates["tex_enumerate"] { pre:"Sans, ou avec peu de calcul, en utilisant la forme la plus adaptée, donnez :", items:[
						"Les coordonnées du sommet $S$ de la courbe de $f$"
						"Les solutions de $f(x) = 0$"
						"Les solultions, si elles existent, de $f(x) = #{itemData.tex.yA}$"
						]}
				]
			}
		out
