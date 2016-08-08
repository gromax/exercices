
Exercice.liste.push
	id:29
	title:"Équation du premier degré"
	description:"Résoudre une équation de forme premier degré : $a\\cdot x+b=0$."
	keyWords:["Affine","Algèbre","Équation","Seconde"]
	init: (data) ->
		deno = Proba.aleaEntreBornes 1,5
		A = Vector.makeRandom "A", data.inputs, {deno:deno}
		B = Vector.makeRandom "B", data.inputs
		# Les deux points ne doivent pas être confondus
		while A.sameAs B,"x"
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		x = NumberManager.makeSymbol("x")
		membreGauche = x.toClone().md(A.x,false).am(A.y,false).simplify().tex()
		membreDroite = x.md(B.x,false).am(B.y,false).simplify().tex()
		xCoeff = A.x.toClone().am(B.x,true)
		solutions = [B.y.toClone().am(A.y,true).md(xCoeff,true).simplify()]
		[
			new BEnonce {title:"Énoncé", zones:[{body:"enonce", html:"<p>On considère l'équation : $#{ membreGauche }= #{ membreDroite }$.</p><p>Vous devez donner la ou les solutions de cette équations, si elles existent.</p><p><i>S'il n'y a pas de solution, écrivez $\\varnothing$. s'il y a plusieurs solutions, séparez-les avec ;</i></p>"}]}
			new BSolutions {
				data:data
				bareme:100
				solutions:solutions
			}
		]
