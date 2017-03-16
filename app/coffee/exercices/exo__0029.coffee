
Exercice.liste.push
	id:29
	title:"Équation du premier degré"
	description:"Résoudre une équation de forme premier degré : $a\\cdot x+b=0$."
	keyWords:["Affine","Algèbre","Équation","Seconde"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs, values:[ { values:{min:-30, max:30}, denominator:{min:1, max:5} } ] }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[A] }).save(data.inputs)
		data.mg = membreGauche = mM.exec(["x", A.x, "*", A.y, "+"], {simplify:true}).tex()
		data.md = membreDroite = mM.exec(["x", B.x, "*", B.y, "+"], {simplify:true}).tex()
		solutions = [ mM.exec([B.y, A.y, "-", A.x, B.x, "-", "/"], {simplify:true}) ]
		[
			new BEnonce {title:"Énoncé", zones:[{body:"enonce", html:"<p>On considère l'équation : $#{ membreGauche }= #{ membreDroite }$.</p><p>Vous devez donner la ou les solutions de cette équations, si elles existent.</p><p><i>S'il n'y a pas de solution, écrivez $\\varnothing$. s'il y a plusieurs solutions, séparez-les avec ;</i></p>"}]}
			new BListe {
				title:"Solutions"
				data:data
				bareme:100
				touches:["empty"]
				liste:[{
					name:"solutions"
					tag:"$\\mathcal{S}$"
					large:true
					solutions:solutions
				}]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:"Équations du premier degré."
			contents:[
				"Résoudre :"
				Handlebars.templates["tex_enumerate"] {
					items: ({title:"$#{itemData.mg} = #{itemData.md}$"} for item in data)
					large:false
				}
			]
		}
