
Exercice.liste.push
	id:10
	title:"Équation du second degré"
	description:"Résoudre une équation du second degré."
	keyWords:["Analyse","Trinome","Équation","Racines","Première"]
	options: {
		d:{ tag:"Résoudre dans" , options:["Réels", "Complexes"] , def:0 }
	}
	init: (data) ->
		dansR = data.options.d.value is 0
		inp = data.inputs
		if (typeof inp.a isnt "undefined") and (typeof inp.b isnt "undefined") and (typeof inp.c isnt "undefined")
			[a,b,c] = ( mM.toNumber(item) for item in [inp.a, inp.b, inp.c] )
		else
			# 1 fois sur 4, on aura un delta<0 pour une équation dans R
			# 1 fois sur 2 si dans C
			if dansR then al = mM.alea.real [1,2,3,4]
			else al = mM.alea.real [1,2]
			a = mM.alea.number [-2,-1,1,2,3]
			x0 = mM.alea.number {min:-10, max:10}
			b = mM.exec [-2,x0,a, "*","*" ], {simplify:true}
			d = mM.alea.number {min:0, max:10}
			if al is 1 then c = mM.exec [x0, x0, "*", d, d, "*", "+", a, "*"], {simplify:true}
			else c = mM.exec [x0, d, "-", x0, d, "+", "*", a, "*"], {simplify:true}
			inp.a = String(a)
			inp.b = String(b)
			inp.c = String(c)
		poly = mM.polynome.make { coeffs:[c, b, a] }
		data.equation = poly.tex()+" = 0"
		[
			new BEnonce {
				zones:[{
					body:"enonce"
					html: "On considère l'équation : $#{poly.tex()}=0$, dans $\\mathbb{#{if dansR then "R" else "C"}}$."
				}]
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
			new BSolutions {
				data:data
				bareme:80
				touches:["sqrt"]
				aide: oHelp.trinome.racines
				solutions:mM.polynome.solve.exact poly, {y:0, imaginaire:not dansR}
			}
		]
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		if data[0]?.options.d.value is 0 then title = "Résoudre dans $\\mathbb{R}$"
		else title = "Résoudre dans $\\mathbb{C}"
		{
			title:title
			content:Handlebars.templates["tex_enumerate"] { items: ("$#{item.equation}$" for item in data), large:slide is true }
		}

