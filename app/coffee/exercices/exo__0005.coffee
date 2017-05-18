
Exercice.liste.push
	id:5
	title:"Distance entre deux points"
	description:"Dans un repère orthonormé, calculer la distance entre deux points. L'exercice existe aussi dans une variante où les coordonnées sont données sous forme complexe."
	keyWords:["Géométrie", "Repère", "Seconde", "Complexes", "1STL"]
	options: {
		a:{ tag:"complexes", options:["non", "oui"], def:0}
	}
	init: (data) ->
		A = mM.alea.vector({ name:"A", def:data.inputs }).save(data.inputs)
		B = mM.alea.vector({ name:"B", def:data.inputs, forbidden:[A] }).save(data.inputs)
		gAB = A.toClone().minus(B).norme()
		if data.options.a.value is 0
			enonce = "<p>On se place dans un repère orthonormé $(O;I,J)$</p><p>On donne deux points $#{A.texLine()}$ et $#{B.texLine()}$.</p><p>Il faut déterminer la valeur exacte de la distance $AB$."
			data.tex = { A:A.texLine(), B:B.texLine() }
		else
			zA = A.affixe().tex()
			zB = B.affixe().tex()
			enonce = "<p>Dans le plan complexe, on donne deux points $A$, d'affixe $z_A=#{zA}$ et $B$, d'affixe $z_B=#{zB}$.</p><p>Il faut déterminer la valeur exacte de la distance $AB$."
			data.tex = { A:zA, B:zB }
		[
			new BEnonce {
				zones:[
					{body:"enonce", html:enonce}
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Distance $AB$"
				liste:[{tag:"$AB$", name:"AB", description:"Distance AB", good:gAB}]
				aide: oHelp.geometrie.analytique.distance.concat oHelp.interface.sqrt
				touches:["sqrt"]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		if data[0].options.a.value is 0
			{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre:"Dans le repère orthonormé $(O;I,J)$, on vous donne les coordonnées de $A$ et $B$. Dans chaque cas, donnez la valeur exacte de $AB$."
					items: ("$#{item.tex.A}$ et $#{item.tex.B}$" for item in data)
				}
			}
		else
			{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre:"Dans le plan complexe, on vous donne les affixes des points $A$ et $B$. Dans chaque cas, donnez la valeur exacte de $AB$."
					items: ("$z_A = #{item.tex.A}$ et $z_B = #{item.tex.B}$" for item in data)
				}
			}
