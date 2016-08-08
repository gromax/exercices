
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
			a = NumberManager.makeNumber(inp.a)
			b = NumberManager.makeNumber(inp.b)
			c = NumberManager.makeNumber(inp.c)
		else
			# 1 fois sur 4, on aura un delta<0 pour une équation dans R
			# 1 fois sur 2 si dans C
			if dansR then al = Proba.aleaEntreBornes(1,4)
			else al = Proba.aleaEntreBornes(1,2)
			a=0
			a = Proba.aleaEntreBornes(-2,3) while a is 0
			a = NumberManager.makeNumber(a)
			if al is 1
				im = Proba.aleaEntreBornes(1,10)
				re = Proba.aleaEntreBornes(-10,10)
				b = NumberManager.makeNumber(-2*re*a)
				c = NumberManager.makeNumber((re*re+im*im)*a)
			else
				x1 = x2 = Proba.aleaEntreBornes(-10,10)
				x2 = Proba.aleaEntreBornes(-10,10)
				b = NumberManager.makeNumber((-x1-x2)*a)
				c = NumberManager.makeNumber(x1*x2*a)
			inp.a = String(a)
			inp.b = String(b)
			inp.c = String(c)
		poly = Polynome.make([c, b, a])
		[
			new BEnonce {
				zones:[{
					body:"enonce"
					html: Handlebars.templates.equation { gauche:poly.tex(), droite:"0", ensemble:if dansR then "$\\mathbb{R}$" else "$\\mathbb{C}$" }
				}]
			}
			new BDiscriminant {
				data:data
				bareme:20
				discriminant:poly.discriminant()
			}
			new BSolutions {
				data:data
				bareme:80
				touches:["sqrt"]
				aide: oHelp.trinome.racines
				solutions:poly.solveExact(0,not dansR)
			}
		]
