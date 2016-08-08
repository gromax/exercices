
Exercice.liste.push
	id:9
	title:"Expression d'une fonction affine"
	description:"On connaît deux valeurs d'une fonction affine. Il faut en déduire l'expression de la fonction."
	keyWords:["Analyse","Fonction","Expression","Affine","Seconde"]
	init: (data) ->
		A = Vector.makeRandom "A", data.inputs
		B = Vector.makeRandom "B", data.inputs
		# Les deux abscisses doivent être différentes
		while A.sameAs B,"x"
			B = Vector.makeRandom "B", data.inputs, { overwrite:true }
		droite = Droite2D.par2Pts A,B
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:"<p>On considère une fonction affine $f$ telle que $#{A.texFunc("f")}$ et $#{B.texFunc("f")}$.</p><p>On sait que $f(x)=a\\cdot x+b$. Vous devez donner $a$ et $b$.</p>"}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Valeurs de $a$ et $b$"
				liste:[
					{
						tag:"$a$"
						name:"a"
						description:"Valeur de a"
						good:droite.m()
						params:
							custom:(output)->
								if NumberManager.equal(output.goodObject.toClone().inverse(), output.userObject) then output.coeffDirecteur_inverse = true
							customTemplate:true
					}
					{
						tag:"$b$"
						name:"b"
						description:"Valeur de b"
						good:droite.p()
					}
				]
				aide: oHelp.fonction.affine.expression
			}
		]
