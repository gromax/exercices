
Exercice.liste.push
	id:30
	title: "Suites et termes général et récurence"
	description: "On donne l'expression de suites et il faut l'associer à la forme donnée par récurence."
	keyWords:["Analyse", "Suite", "Première"]
	template:"2cols"
	init: (data) ->
		items=[]
		inp = data.inputs
		if inp.q1? then q1 = Number inp.q1
		else q1 = inp.q1 = Proba.aleaEntreBornes(1,10,true)
		if inp.q2? then q2 = Number inp.q2
		else q2 = inp.q2 = Proba.aleaEntreBornes(1,10,true)
		if inp.u1? then u1 = Number inp.u1
		else u1 = inp.u1 = Proba.aleaEntreBornes(1,10,true)
		if inp.u2? then u2 = Number inp.u2
		else u2 = inp.u2 = Proba.aleaEntreBornes(1,10,true)
		# u1 et q1 sont le premier terme et la raison pour une paire de suites arithmétique - géométrique. u2 et q2 pour une deuxième paire
		# La première suite est arithmétique
		u=Suite.arithmetique("u",u1,q1,0)
		items.push { a:"u_n=#{u.tex_expl()}", b:"u_{n+1}=#{u.tex_rec()}", c:u.u_nMin.tex()}
		# Le seconde est une suite géométrique
		u=Suite.geometrique("u",u1,q1,0)
		items.push { a:"u_n=#{u.tex_expl()}", b:"u_{n+1}=#{u.tex_rec()}", c:u.u_nMin.tex()}
		# La troisième est arithmétique
		u=Suite.arithmetique("u",u2,q2,0)
		items.push { a:"u_n=#{u.tex_expl()}", b:"u_{n+1}=#{u.tex_rec()}", c:u.u_nMin.tex()}
		# La quatrième est géométrique
		u=Suite.geometrique("u",u2,q2,0)
		items.push { a:"u_n=#{u.tex_expl()}", b:"u_{n+1}=#{u.tex_rec()}", c:u.u_nMin.tex()}
		o = h_random_order(items.length,inp.o)
		inp.o = o.join("")
		# On affecte le rang, ce qui revient à affecter les couleurs
		item.rank = o[i] for item,i in items
		l_gauche = Tools.arrayShuffle ({title:"$"+item.a+"$", color:colors[item.rank].html} for item in items)
		l_droite = ({title:"$#{item.b}$ et $u_0=#{item.c}$", rank:item.rank} for item in items)
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
