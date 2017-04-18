
Exercice.liste.push
	id:58
	title:"Loi exponentielle"
	description:"Calculer des probabilités avec la loi exponentielle."
	keyWords:["probabilités","exponentielle", "TSTL"]
	init: (data) ->
		inp = data.inputs
		if (typeof inp.l is "undefined") then inp.l = l = mM.alea.real( {min:1, max:100, coeff:0.0001} )
		E = 1/l

		# Symbole d'inégalité
		# 8 configurations possibles
		if (typeof data.inputs.sy is "undefined") then data.inputs.sy = mM.alea.real [0,1,2]
		sy = Number data.inputs.sy
		if sy is 0
			# Pas de borne à gauche
			a = 0
			ens = "T"
		else
			# a est entre 20% et 100% de E
			if (typeof data.inputs.a is "undefined") then data.inputs.a = mM.alea.real({min:20, max:100})
			a = Number data.inputs.a
		# borne droite
		if sy isnt 2
			# b varie entre a+10% de E et 200% de E
			if (typeof data.inputs.b is "undefined") then data.inputs.b = mM.alea.real({min:a+10, max:200})
			b = Math.round( (Number data.inputs.b)*E/100 )
		a = Math.round(a*E/100)
		# choix de l'exercice : on fournit E(T) et on demande lambda, ou on fournit lambda et on demande T ?
		if typeof inp.dl is "undefined" then inp.dl = mM.alea.in ["y", "n"]

		habillage = mM.alea.in [
			{
				texte:"Une usine fabrique des ampoules. On s'intéresse à la durée de vie d'une ampoule prélevée dans le stock. Soit $T$ cette durée de vie en heures."
				unite:"h"
				question: switch sy
					when 0 then "Soit A l'événement : L'ampoule a une durée de vie inférieure à #{b} heures."
					when 2 then "Soit A l'événement : L'ampoule a une durée de vie supérieure à #{a} heures."
					else "Soit A l'événement : L'ampoule a une durée de vie comprise entre #{a} et #{b} heures."
			}
			{
				texte:"Des bactéries sont soumis à un antibiotique. On s'intéresse à la durée de vie d'une  bactérie prise au hasard. Soit $T$ cette durée de vie en minutes."
				unite:"min"
				question: switch sy
					when 0 then "Soit A l'événement : La bactérie a une durée de vie inférieure à #{b} minutes."
					when 2 then "Soit A l'événement : La bactérie a une durée de vie supérieure à #{a} minutes."
					else "Soit A l'événement : La bactérie a une durée de vie comprise entre #{a} et #{b} minutes."
			}
			{
				texte:"On s'intéresse à un stock des objets radioactifs. Pour chacun de ces objets, $T$ est le temps en jours pendant lequel sa radioactivité reste trop importante. On prélève un de ces objets au hasard."
				unite:"j"
				question: switch sy
					when 0 then "Soit A l'événement : L'objet reste radioactif pendant moins de #{b} jours."
					when 2 then "Soit A l'événement : L'objet reste radioactif pendant plus de #{a} jours."
					else "Soit A l'événement : L'objet reste radioactif entre #{a} et #{b} jours."
			}
		]
		if inp.dl is "y"
			E = Math.floor(E)
			l = 1/E
			premiereQuestion = new BListe {
				text:"Donnez le paramètre $\\lambda$ à $10^{-4}$ près"
				data:data
				bareme:100
				title:"Paramètre $\\lambda$"
				liste:[{
					tag:"$\\lambda$"
					name:"l"
					description:"Valeur à 0,000 1 près"
					good:l
					arrondi:-4
				}]
				aide: [
					"La densité de probabilité d'une loi exponentielle de paramètre $\\lambda$ est donnée par la fonction $t\\mapsto \\lambda e^{-\\lambda t}$"
					"L'espérance d'une variable aléatoire $T$ suivant la loi exponentielle de paramètre $\\lambda$ est $E(T) = \\frac{1}{\\lambda}$."
				]
			}
			texteEnnonce = habillage.texte+" $T$ suit une loi exponentielle et on sait que la moyenne de $T$ est $E(T) = #{E}~#{habillage.unite}$."
			premiereQuestionPourTex = "Donnez le paramètre $\\lambda$ à $10^{-4}$ près"
		else
			premiereQuestion = new BListe {
				text:"Donnez l'espérance $E(T)$ à l'unité près"
				data:data
				bareme:100
				title:"Espérance"
				liste:[{
					tag:"$E(T)$"
					name:"E"
					description:"Valeur à 1 près"
					good:E
					arrondi:0
				}]
				aide: [
					"La densité de probabilité d'une loi exponentielle de paramètre $\\lambda$ est donnée par la fonction $t\\mapsto \\lambda e^{-\\lambda t}$"
					"L'espérance d'une variable aléatoire $T$ suivant la loi exponentielle de paramètre $\\lambda$ est $E(T) = \\frac{1}{\\lambda}$."
				]
			}
			texteEnnonce = habillage.texte+" $T$ suit une loi exponentielle de paramètre $\\lambda = #{numToStr(l,4)}~#{habillage.unite}^{-1}$."
			premiereQuestionPourTex = "Donnez l'espérance $E(T)$ à l'unité près"
		if sy is 2 then goodP = Math.exp(-l*a)
		else goodP = Math.exp(-l*a) - Math.exp(-l*b)

		data.tex = {
			texteEnnonce:texteEnnonce
			premiereQuestion:premiereQuestionPourTex
			deuxiemeQuestion:habillage.question+" Donnez $p(A)$ à $10^{-3}$ près."
		}

		[
			new BEnonce {zones:[
				{
					body:"enonce"
					html:"<p>#{texteEnnonce}</p>"
				}
			]}
			premiereQuestion
			new BListe {
				data:data
				bareme:100
				title:"Calcul de probabilité"
				text:habillage.question+" Donnez $p(A)$ à $10^{-3}$ près."
				liste:[
					{
						tag:"$p(A)$"
						name:"p"
						description:"Valeur à 0,001 près"
						good:goodP
						arrondi:-3
					}
				]
				aide: [
					"La densité de probabilité d'une loi exponentielle de paramètre $\\lambda$ est donnée par la fonction $t\\mapsto \\lambda e^{-\\lambda t}$"
					"En général on calcul $p(a<T<b) = \\int_a^b \\lambda e^{-\\lambda t} dt = e^{-\\lambda a} - e^{-\\lambda b}$ avec $a$ et $b$ dans $[0;+\\infty[$."
					"Dans le calcul précédent, quand $b \\to +\\infty$, alors $e^{-\\lambda b} \\to 0$"
				]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			out.push {
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					pre:itData.tex.texteEnnonce
					items: [
						itData.tex.premiereQuestion
						itData.tex.deuxiemeQuestion
					]
				}
			}
		out
