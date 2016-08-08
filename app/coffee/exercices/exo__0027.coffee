
Exercice.liste.push
	id:27
	title: "Calculs avec les complexes"
	description: "Faire les calculs de base avec les complexes."
	keyWords:["Géométrie", "Complexe", "Première"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		zA = A.affixe()
		zB = B.affixe()
		gSomme = zA.toClone().am(zB,false)
		gProduit = zA.toClone().md(zB,false).simplify()
		gInverse = zA.toClone().inverse().simplify()
		gQuotient = zB.toClone().md(zA, true).simplify()
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère les deux nombres complexes : $z = #{zA.tex()}$ et $z' = #{zB.tex()}$.</p><p>Donnez les résultats des calculs suivants :</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Calculs"
				liste:[
					{tag:"$z+z'$", name:"s", description:"Somme", good:gSomme},
					{tag:"$z\\times z'$", name:"p", description:"Produit", good:gProduit},
					{tag:"$\\frac{1}{z}$", name:"i", description:"Inverse", good:gInverse, params:{formes:"FRACTION"}},
					{tag:"$\\frac{z}{z'}$", name:"q", description:"Quotient", good:gQuotient, params:{formes:"FRACTION"}}
				]
				aide: oHelp.complexes.basics
			}
		]
