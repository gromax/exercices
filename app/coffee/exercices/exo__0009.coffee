
Exercice.liste.push
	id:9
	title:"Expression d'une fonction affine"
	description:"On connaît deux valeurs d'une fonction affine. Il faut en déduire l'expression de la fonction."
	keyWords:["Analyse","Fonction","Expression","Affine","Seconde"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[ {axe:"x", coords:A} ] }).save(data.inputs)
		droite = mM.droite.par2pts A,B
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
								if output.goodObject.toClone().inverse().equals(output.userObject) then output.coeffDirecteur_inverse = true
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
