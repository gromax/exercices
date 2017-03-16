
Exercice.liste.push
	id:30
	title: "Suites et termes général et récurrence"
	description: "On donne l'expression de suites et il faut l'associer à la forme donnée par récurence."
	keyWords:["Analyse", "Suite", "Première"]
	template:"2cols"
	init: (data) ->
		items=[]
		inp = data.inputs
		if inp.q1? then q1 = Number inp.q1
		else q1 = inp.q1 = mM.alea.real( { values:{min:1, max:10}, sign:true } )
		if inp.q2? then q2 = Number inp.q2
		else q2 = inp.q2 = mM.alea.real( { values:{min:1, max:10}, sign:true } )
		if inp.u1? then u1 = Number inp.u1
		else u1 = inp.u1 = mM.alea.real( { values:{min:1, max:10}, sign:true } )
		if inp.u2? then u2 = Number inp.u2
		else u2 = inp.u2 = mM.alea.real( { values:{min:1, max:10}, sign:true } )
		# u1 et q1 sont le premier terme et la raison pour une paire de suites arithmétique - géométrique. u2 et q2 pour une deuxième paire
		# La première suite est arithmétique
		u=mM.suite.arithmetique { premierTerme:{ valeur:u1, rang:0 }, raison:q1 }
		items.push { a:"u_n=#{u.explicite().tex()}", b:"u_{n+1}=#{u.recurence().tex()}", c:u.calc(0).tex()}
		# Le seconde est une suite géométrique
		u=mM.suite.geometrique { premierTerme:{ valeur:u1, rang:0}, raison:q1}
		items.push { a:"u_n=#{u.explicite().tex()}", b:"u_{n+1}=#{u.recurence().tex()}", c:u.calc(0).tex()}
		# La troisième est arithmétique
		u=mM.suite.arithmetique { premierTerme:{ valeur:u2, rang:0 }, raison:q2 }
		items.push { a:"u_n=#{u.explicite().tex()}", b:"u_{n+1}=#{u.recurence().tex()}", c:u.calc(0).tex()}
		# La quatrième est géométrique
		u=mM.suite.geometrique { premierTerme:{ valeur:u2, rang:0 }, raison:q2 }
		items.push { a:"u_n=#{u.explicite().tex()}", b:"u_{n+1}=#{u.recurence().tex()}", c:u.calc(0).tex()}
		o = h_random_order(items.length,inp.o)
		inp.o = o.join("")
		# On affecte le rang, ce qui revient à affecter les couleurs
		item.rank = o[i] for item,i in items
		l_gauche = arrayShuffle ({title:"$"+item.a+"$", color:colors(item.rank).html} for item in items)
		l_droite = ({title:"$#{item.b}$ et $u_0=#{item.c}$", rank:item.rank} for item in items)
		data.tex = {
			gauche:( it.title for it in l_gauche )
			droite:( it.title for it in l_droite )
		}
		[
			new BEnonce { zones:[{body:"enonce", html:"<p>À gauche, des suites données explicitement. À droite elles sont données par récurence.", "Associez-les en utilisant les boutons de couleurs à droite.</p>"}]}
			new BEnonce {
				zone:"gauche"
				template:"std_color_menu"
				title:"Définitions explicites",
				items:l_gauche,
				noForm:true
			}
			new BChoice {
				data:data
				bareme:100
				liste:l_droite
				zone:"droite"
				title:"Cliquez sur les rectangles pour choisir associer chaque item de droite à un item de gauche, puis validez"
			}
		]
	tex:(data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			col1 = Handlebars.templates["tex_enumerate"] {
				numero:"a)"
				items:itData.tex.gauche
			}
			col2 = Handlebars.templates["tex_enumerate"] {
				numero:"\\hspace{-7mm}1)"
				items:itData.tex.droite
			}
			content = Handlebars.templates["tex_plain"] {
				multicols:2
				center:true
				contents:[col1, "\\columnbreak", col2]
			}
			out.push {
				title:@title
				content: Handlebars.templates["tex_plain"] {
					contents:["Associez les formes explicites et les formes récurrentes deux à deux.", content]
					large:false
				}
			}
		out


