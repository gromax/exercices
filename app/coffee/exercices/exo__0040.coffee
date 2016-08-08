
Exercice.liste.push
	id:40
	title:"Somme de fractions"
	description:"Ajouter des fractions et simplifier le résultat."
	keyWords:["Calcul","Collège","Fraction"]
	init: (data) ->
		if data.inputs.e? then expression = NumberManager.makeNumber(data.inputs.e, {simplify:false})
		else
			values = []
			N=2
			while values.length<N
				values.push NumberManager.makeNumber({numerator:Proba.aleaEntreBornes(1,30,true), denominator:Proba.aleaEntreBornes(1,7)})
				expression = NumberManager.makeSum values
				data.inputs.e = String expression
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>Soit $x=#{expression.tex()}$. Donnez $x$ sous forme d'une fraction réduite.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Simplification de $x$"
				liste:[{tag:"$x$", name:"x", description:"Fraction réduite", good:expression.toClone().simplify()}]
			}
		]
