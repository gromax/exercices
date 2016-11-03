
Exercice.liste.push
	id:42
	title: "Termes d'une suite récurente"
	description: "Calculer les termes d'une suite donnée par récurence."
	keyWords:["Analyse", "Suite", "Première"]
	init: (data) ->
		inp = data.inputs
		if inp.a? then a = Number inp.a
		else a = inp.a = mM.alea.real({min:40, max:90, sign:true})/100
		if inp.b? then b = Number inp.b
		else b = inp.b = mM.alea.real { min:1, max:20 }
		if inp.u0? then u0 = Number inp.u0
		else u0 = inp.u0 = mM.alea.real { min:0, max:20 }
		u = mM.suite.arithmeticogeometrique { premierTerme:{ valeur:u0, rang:0 }, r:b, q:a }
		u1 = u.calc(1)
		u2 = u.calc(2)
		u3= u.calc(3)
		u10= u.calc(10)
		formule= u.recurence().tex()
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère la suite $(u_n)$ définie par $u_0=#{u0}$ et $u_{n+1}= #{formule}$ pour $n\\geqslant 0$.</p><p>On demande de calculer les termes suivants à $0,01$ près :</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Termes de la suite"
				liste:[{tag:"$u_1$", name:"u1", description:"Terme de rang 1", good:u1, params:{arrondi:-2}}, {tag:"$u_2$", name:"u2", description:"Terme de rang 2", good:u2, params:{arrondi:-2}}, {tag:"$u_3$", name:"u3", description:"Terme de rang 3", good:u3, params:{arrondi:-2}}, {tag:"$u_{10}$", name:"u10", description:"Terme de rang 10", good:u10, params:{arrondi:-2}}]
			}
		]
