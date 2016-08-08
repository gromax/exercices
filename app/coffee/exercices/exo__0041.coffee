
Exercice.liste.push
	id:41
	title: "Termes d'une suite explicite"
	description: "Calculer les termes d'une suite donnée explicitement."
	keyWords:["Analyse", "Suite", "Première"]
	init: (data) ->
		# Debug_old_version
		if data.inputs.p? then data.inputs.p = data.inputs.p.replace "x", "n"
		# Fin debug
		if data.inputs.p? then poly = NumberManager.makeNumber(data.inputs.p).toPolynome("n")
		else
			a = Proba.aleaEntreBornes(1,3,true)
			b = Proba.aleaEntreBornes(1,10,true)
			c = Proba.aleaEntreBornes(1,20,true)
			poly = Polynome.make([c,b,a], "n")
			data.inputs.p = String poly
			console.log data.inputs.p
		u0=poly.toNumber(0)
		u1=poly.toNumber(1)
		u2=poly.toNumber(2)
		u10=poly.toNumber(10)
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère la suite $(u_n)$ définie par $u_n = #{poly.tex()}$ pour $n\\geqslant 0$.</p><p>On demande de calculer les termes suivants :</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Termes de la suite"
				liste:[{tag:"$u_0$", name:"u0", description:"Terme de rang 0", good:u0}, {tag:"$u_1$", name:"u1", description:"Terme de rang 1", good:u1}, {tag:"$u_2$", name:"u2", description:"Terme de rang 2", good:u2}, {tag:"$u_{10}$", name:"u10", description:"Terme de rang 10", good:u10}]
			}
		]
