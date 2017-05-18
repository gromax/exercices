
Exercice.liste.push
	id:11
	title:"Équation somme et produit"
	description:"On connaît la somme et le produit de deux nombres, il faut calculer ces nombres."
	keyWords:["Analyse","Trinome","Équation","Racines","Première"]
	init: (data) ->
		i = data.inputs
		if (typeof i.S isnt "undefined") and (typeof i.P isnt "undefined")
			S = mM.toNumber i.S
			P = mM.toNumber i.P
		else
			x1 = x2 = mM.alea.real { min:-40, max:40 }
			x2 = mM.alea.real { min:-40, max:40 } while x2 is x1
			S = data.S = mM.toNumber(i.S = x1+x2)
			P = data.P = mM.toNumber(i.P = x1*x2)
		data.tex = { S:S, P:P }
		poly = mM.polynome.make { coeffs:[P.toClone(), S.toClone().opposite(), 1] }
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On cherche les valeurs de $x$ et $y$ telles que $x+y=#{S.tex()}$ et $x\\cdot y =#{P.tex()}$.</p>"}]}
			new BListe {
				title:"Équation à rédoudre"
				data:data
				bareme:20
				good:poly
				liste:[{
					tag:"(E)"
					name:"poly"
					good:poly.toNumberObject()
					large:true
					postTag:"$=0$"
					description:"Équation à résoudre"
				}]
				touches:[{name:"sqr-button", title:"carré", tag:"$x^2$", pre:"", post:"x^2", recouvre:false}]
			}
			new BListe {
				title: "Calcul du discriminant $\\Delta$"
				data:data
				bareme:20
				liste: [
					tag:"$\\Delta =$"
					name:"delta"
					description:"Discriminant"
					good:poly.discriminant()
				]
				aide: oHelp.trinome.discriminant
			}
			new BListe {
				title:"Solutions"
				data:data
				bareme:60
				touches:["empty","sqrt"]
				aide:oHelp.trinome.racines
				liste:[{
					name:"solutions"
					tag:"$\\mathcal{S}$"
					large:true
					solutions:mM.polynome.solve.exact poly, {y:0}
				}]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Dans chaque cas, déterminez $x$ et $y$."
				items: ("$x+y=#{item.tex.S}$ et $x\\cdot y = #{item.tex.P}$" for item in data)
			}
		}
