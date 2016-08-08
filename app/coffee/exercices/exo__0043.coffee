
Exercice.liste.push
	id:43
	title: "Suites et intérêts composés"
	description: "On donne le rendement annuel d'un placement. On cherche à savoir au bout de combien de temps on aura doublé le capital initial."
	keyWords:["Analyse", "Suite", "Première"]
	init: (data) ->
		inp = data.inputs
		if typeof inp.r is "undefined" then inp.r = Proba.aleaEntreBornes(15,50)/10
		else inp.r = Number inp.r
		if typeof inp.c is "undefined" then inp.c = Proba.aleaEntreBornes(1,8)
		else inp.c = Number inp.c
		q = 1+inp.r/100 # Raison
		c0=inp.c*1000 # Premier terme
		n = Math.ceil(Math.log(2)/Math.log(q)) # Doublement
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Le 1 janvier 2010, on place la somme de #{c0} € sur un compte bancaire qui rapporte tous les ans #{inp.r.toStr()}% d'intérêts composés.", "Soit $(C_n)$ la suite représentant le capital sur le compte au 1 janvier de l'année 2010$+n$.</p>"}]}
			new BListe {
				data:data
				bareme:50
				title:"Paramètres de la suite"
				text:"$(C_n)$ est une suite géométrique. Donnez son premier terme et sa raison."
				liste:[{tag:"$C_0$", name:"c0", description:"Premier terme", good:c0}, {tag:"$q$", name:"q", description:"Raison de la suite", good:q}]
			}
			new BListe {
				data:data
				bareme:50
				title:"Doublement du capital"
				text:"Au bout d'un certain temps, le capital sur le compte aura doublé. Donnez le rang $n$ et l'année correspondante."
				liste:[{tag:"$n$", name:"n", description:"Rang du doublement", good:n}, {tag:"Année", name:"a", description:"Année du doublement", good:2010+n}]
			}
		]
