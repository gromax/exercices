
Exercice.liste.push
	id:27
	title: "Calculs avec les complexes"
	description: "Faire les calculs de base avec les complexes."
	keyWords:["Géométrie", "Complexe", "Première"]
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs }).save(data.inputs)
		zA = A.affixe()
		zB = B.affixe()
		gSomme = mM.exec [zA, zB, "+"], {simplify:true}
		gProduit = mM.exec [zA, zB, "*"], {simplify:true}
		gInverse = mM.exec [zA, "^-1"], {simplify:true}
		gQuotient = mM.exec [zA, zB, "/"], {simplify:true}
		data.tex = {
			zA: zA.tex()
			zB: zB.tex()
		}
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère les deux nombres complexes : $z = #{zA.tex()}$ et $z' = #{zB.tex()}$.</p><p>Donnez les résultats des calculs suivants :</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Calculs"
				liste:[
					{
						tag:"$z+z'$"
						name:"s"
						description:"Somme"
						good:gSomme
					}
					{
						tag:"$z\\times z'$"
						name:"p"
						description:"Produit"
						good:gProduit
					}
					{
						tag:"$\\frac{1}{z}$"
						name:"i"
						description:"Inverse"
						good:gInverse
						formes:"FRACTION"
					}
					{
						tag:"$\\frac{z}{z'}$"
						name:"q"
						description:"Quotient"
						good:gQuotient
						formes:"FRACTION"
					}
				]
				aide: oHelp.complexes.basics
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre:"On vous donne $z$ et $z'$. Calculez $z+z'$, $z\\times z'$, $\\frac{1}{z}$ et $\\frac{z}{z'}$"
				items: ("$z = #{item.tex.zA}$ et $z' = #{item.tex.zB}$" for item in data)
				large:false
			}
		}
