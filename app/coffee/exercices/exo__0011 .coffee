
Exercice.liste.push
	id:11
	title:"Équation somme et produit"
	description:"On connaît la somme et le produit de deux nombres, il faut calculer ces nombres."
	keyWords:["Analyse","Trinome","Équation","Racines","Première"]
	init: (data) ->
		i = data.inputs
		if (typeof i.S isnt "undefined") and (typeof i.P isnt "undefined")
			S = NumberManager.makeNumber(i.S)
			P = NumberManager.makeNumber(i.P)
		else
			x1 = x2 = Proba.aleaEntreBornes(-40,40)
			x2 = Proba.aleaEntreBornes(-40,40) while x2 is x1
			S = data.S = NumberManager.makeNumber(i.S = x1+x2)
			P = data.P = NumberManager.makeNumber(i.P = x1*x2)
		poly = Polynome.make([P.toClone(), S.toClone().opposite(), 1])
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On cherche les valeurs de $x$ et $y$ telles que $x+y=#{S.tex()}$ et $x\\cdot y =#{P.tex()}$.</p>"}]}
			new Brique {
				data:data
				bareme:20
				good:poly
				needed: ["poly"]
				ask: () ->
					@container.html Handlebars.templates.std_panel {
						title:"Équation à rédoudre"
						focus:true
						zones:[
							{
								body:"champ"
								html:Handlebars.std_form {
									inputs:[{postTag:"$=0$", description:"Équation à résoudre", name:"poly"}]
									clavier:[{name:"sqr-button", title:"carré", tag:"$x^2$"}]
									help_target:@data.divId+"_aide"
								}
							}, {
								help:@data.divId+"_aide"
								html:Handlebars.templates.help {somme_produit:true}
							}
						]
					}
					@gc = new GestClavier $("input[name='poly']",@container)
					$("button[name='sqr-button']",@container).on 'click', (event) => @gc.clavier("","x^2",false)
					$("form",@container).on 'submit', (event) =>
						@a.poly = $("input[name='poly']",@container).val()
						@run true
						false
					$("input[name='poly']",@container).focus()
				ver: () ->
					si = new Parser @a.poly, {developp:true}
					polyUserObj = si.object.toPolynome("x")
					polyUserTex = polyUserObj.tex()
					polyGoodTex = @config.good.tex()
					if (polyUserObj.minus(@config.poly).simplify().isNul())
						liste_cor = [{ text:"Vous avez répondu $#{polyUserTex}=0$. Bonne réponse.", color:"ok" }]
						@data.note += @bareme
					else
						liste_cor = [
							{ text:"Vous avez répondu $#{polyUserTex}=0$.", color:"error" }
							{ text:"La somme  $x+y$ est $S = #{@data.S.tex()}$ et le produit $x\\cdot y$ est $P = #{@data.P.tex()}$, donc on sait que l'équation est de la forme $x^2-S x+P=0$, c'est à dire ici : $#{polyGoodTex}=0$.", color:"error"}
						]
					@container.html Handlebars.templates.std_panel {
						title:"Équation à rédoudre : $#{polyGoodTex}=0$"
						zones:[{
							list:"correction"
							html:Handlebars.templates.listItem liste_cor
						}]
					}
			}
			new BDiscriminant {
				data:data
				bareme:20
				discriminant:poly.discriminant()
			}
			new BSolutions {
				data:data
				bareme:60
				touches:["sqrt"]
				aide:oHelp.trinome.racines
				solutions:poly.solveExact(0,false)
			}
		]
