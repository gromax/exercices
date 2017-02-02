
Exercice.liste.push
	id:54
	title:"Équations différentielles du premier ordre"
	description:"Résoudre des équations différentielles du premier ordre, avec coefficients constant et second membre."
	keyWords:["exponentielle","équation","TSTL","BTS"]
	options: {
		a:{ tag:"second membre" , options:["u' exp(-b/a.t)+Y", "u' exp(-b/a.t)", "Y", "u' exp(-b/a.t) OU Y"] , def:3 }
	}
	init: (data) ->
		# On a une équation de type a.y'+b.y = c avec
		# a <>0
		# c est de la forme u' exp(-b/a.t) + Y
		# a priori, u est un simple polynome de degré 0 ou 1
		optA = data.options.a.value
		if typeof data.inputs.a isnt "undefined" then a = mM.toNumber data.inputs.a
		else
			a = mM.alea.number { min:1, max:10, sign:true }
			data.inputs.a = String a

		if typeof data.inputs.b isnt "undefined" then b = mM.toNumber data.inputs.b
		else
			b = mM.alea.number { min:1, max:10, sign:true }
			data.inputs.b = String b
		# On envisage pour u' une écriture u1.t+u0
		switch
			when typeof data.inputs.u0 isnt "undefined" then u0 = Number data.inputs.u0
			when (optA is 2) or ((optA is 3) and mM.alea.dice(1,2)) then u0 = 0
			else u0 = mM.alea.real { min:1, max:5 }
		data.inputs.u0 = String u0
		# Une fois sur 10, si u0 exite déjà, on ajoute un u1 non nul
		switch
			when typeof data.inputs.u1 isnt "undefined" then u1 = Number data.inputs.u1
			when (u0 isnt 0) and mM.alea.dice(1,10) then u1 = mM.alea.real { min:1, max:5 }
			else u1 = 0
		data.inputs.u1 = String u1
		u_nul = (u0 is 0) and (u1 is 0)
		# On envisage l'ajout d'une constante Y à c(t)
		switch
			when typeof data.inputs.Y isnt "undefined" then Y = Number data.inputs.Y
			when (optA is 1) or (optA is 3) and not u_nul then Y = 0
			when optA is 0 then Y = mM.alea.real { min:0, max:10 }
			else Y = mM.alea.real { min:1, max:10 }
		data.inputs.Y = String Y
		# Valeur de y(0)
		if typeof data.inputs.y0 isnt "undefined" then y0 = Number data.inputs.y0
		else
			y0 = mM.alea.real { min:0, max:10 }
			data.inputs.y0 = String y0
		# le exp(-b/a t) revient tout le temps, je le calcul
		expo = mM.exec [b, "*-", a, "/", "t", "*", "exp"], {simplify:true}
		if (u1 isnt 0) or (u0 isnt 0) then operands = [ u1, "t", "*", u0, "+", expo, "*"]
		else operands = [ 0 ]
		if Y isnt 0 then operands.push(Y,"+")
		c = mM.exec operands, { simplify:true }
		premier_membre_tex = mM.exec([a,"symbol:y'","*",b,"symbol:y","*","+"],{simplify:true}).tex()
		second_membre_tex = c.tex(altFunctionTex:["exp"])
		good_y0 = mM.exec ["symbol:K", expo, "*"], {simplify:true}
		# On précise la forme de la solution générale
		good_y1 = mM.exec [u1, "t", "t", 2, "/", "*", "*", u0, "t", "*", "+", expo, "*", Y, b, "/", "+"], { simplify:true }
		K_good = mM.exec [ y0, Y, b, "/", "-"], { simplify:true }
		good_y = mM.exec [u1, "t", "t", 2, "/", "*", "*", u0, "t", "*", "+", K_good, "+", expo, "*", Y, b, "/", "+"], { simplify:true }
		switch
			when u_nul
				# On est sûr que Y<>0
				forme_y1_tex = "C"
				symboles_a_trouver = ["$C$"]
			when (Y is 0) and (u1 is 0)
				# On est sûr que u0<>0
				forme_y1_tex = mM.exec([ "symbol:a", "t", "*", expo, "*" ]).tex(altFunctionTex:["exp"])
				symboles_a_trouver = ["$a$"]
			when u1 is 0
				# On est sûr que u0<>0 et Y<>0
				forme_y1_tex = mM.exec([ "symbol:a", "t", "*", expo, "*", "symbol:C", "+" ]).tex(altFunctionTex:["exp"])
				symboles_a_trouver = ["$a$", "$C$"]
			when (Y is 0)
				# On est sûr que u1<>0 puisque le cas u1 = 0 et Y = 0 a déjà été traité. On ne sait pas pour u0
				forme_y1_tex = mM.exec([ "symbol:a", "t", 2, "^", "*", "symbol:b", "t", "*", "+", expo, "*"]).tex(altFunctionTex:["exp"])
				symboles_a_trouver = ["$a$", "$b$"]
			else
				# On est sûr que u1<>0 puisque le cas u1 = 0 a déjà été envisagé
				forme_y1_tex = mM.exec([ "symbol:a", "t", 2, "^", "*", "symbol:b", "t", "*", "+", expo, "*", "symbol:C", "+"]).tex(altFunctionTex:["exp"])
				symboles_a_trouver = ["$a$", "$b$", "$C$"]
		data.tex = {
			premier_membre : premier_membre_tex
			second_membre : second_membre_tex
			y0: y0
			p: forme_y1_tex
			symboles_a_trouver: symboles_a_trouver
		}
		[
			new BEnonce {
				title:"Énoncé"
				zones:[
					{
						body:"enonce"
						html:"<p>Soit l'équation différentielle $(E):#{premier_membre_tex} = #{second_membre_tex}$</p>"
					}
					{
						list:"infos"
						items:[
							{class:"warning", html:"Attention : vous devez savoir que dans l'équation $a\\cdot y'+b\\cdot y =\\cdots$, on voit apparaître des calculs de cette forme : $\\exp\\left(-\\frac{b}{a}t\\right)$. Vous noterez le $-\\frac{b}{a}$ sous forme <b>réduite</b> et pas sous forme décimale, sinon votre réponse, même bonne, ne serait pas reconnue."}
							{class:"warning", html:"Vous pouvez écrire $K e^{\\cdots}$ ou $K \\exp(\\cdots)$ pour l'exponentielle, mais faites attention de séparer $\\exp$ et $K$ au minimum d'une espace."}
						]
					}
				]
			}
			new BListe {
				title: "Équation sans second membre"
				text: "<p>Donnez l'expression de $y_0$, solution générale de l'équation : $\\left(E_0\\right) : #{premier_membre_tex} = 0$. Vous noterez $K$ la constante utile."
				data:data
				bareme:50
				liste: [
					tag:"$y_0(t)$"
					name:"y0"
					description:"Solution générale de E0"
					good:good_y0
					params: { goodTex:good_y0.tex(altFunctionTex:["exp"]) }
					large:true
				]
			}
			new BListe {
				title: "Solution particulière"
				text: "<p>Il existe une solution particulière de $(E)$ dont l'expression est de la forme $y_1(t) = #{forme_y1_tex} $. Donnez cette solution en précisant le(s) valeur(s) de #{symboles_a_trouver.join(" ,")}.</p>"
				data:data
				bareme:50
				liste: [
					tag:"$y_1(t)$"
					name:"y1"
					description:"Solution particulière de E"
					good:good_y1
					params: { goodTex:good_y1.tex(altFunctionTex:["exp"]) }
					large:true
				]
			}
			new BListe {
				title: "Solution avec contrainte"
				text: "<p>Soit $y$ une solution de $(E)$ qui vérifie $y(0) = #{y0}$. Donnez l'expression de y.</p>"
				data:data
				bareme:50
				liste: [
					tag:"$y(t)$"
					name:"y"
					description:"Solution telle que y(0) = #{y0}"
					good:good_y
					params: { goodTex:good_y.tex(altFunctionTex:["exp"]) }
					large:true
				]
			}
		]
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		out = []
		for itData in data
			out.push {
				title:@title
				content: Handlebars.templates["tex_enumerate"] {
					pre:"Soit l'équation différentielle $(E):#{itData.premier_membre} = #{itData.second_membre}$"
					items: [
						"Donnez $y_0(t)$, expression de la solution générale de $\\left(E_0\\right):#{itData.premier_membre} = 0$"
						"Une solution générale de $(E)$ est de la forme $y_1(t) = #{itData.forme_y1_tex}. Donnez cette solution en précisant le(s) valeur(s) de #{itData.symboles_a_trouver.join(" ,")}."
						"Soit $y$ une solution de $(E)$ qui vérifie $y(0) = #{itData.y0}$. Donnez l'expression de y."
					]
					large:slide is true
				}
			}
		out

