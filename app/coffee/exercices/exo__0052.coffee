
Exercice.liste.push
	id:52
	title:"Loi normale"
	description:"Calculer des probabilités avec la loi normale."
	keyWords:["probabilités","normale","TSTL"]
	init: (data) ->
		if (typeof data.inputs.std is "undefined") then data.inputs.std = mM.alea.real { min:1, max:50 }
		std = Number data.inputs.std
		if (typeof data.inputs.mu is "undefined") then data.inputs.mu = mM.alea.real({min:0, max:10, coeff:std})
		mu = Number data.inputs.mu
		# Symbole d'inégalité à gauche
		symbs = ["","<","\\leqslant"]
		if (typeof data.inputs.sa is "undefined") then data.inputs.sa = mM.alea.real [0,1,2]
		sa = Number data.inputs.sa
		if sa is 0
			Xa = -1000*std+mu
			a = -101 # utile pour le calcul de b
			ens = "X"
		else
			if (typeof data.inputs.a is "undefined") then data.inputs.a = mM.alea.real({min:-100, max:80})
			a = Number data.inputs.a
			Xa = Math.floor(a*2*std)/100+mu
			ens = "#{numToStr(Xa,2)} #{symbs[sa]} X"
		if (typeof data.inputs.sb is "undefined")
			if sa is 0 then data.inputs.sb = mM.alea.real([1,2])
			else data.inputs.sb = mM.alea.real([0,1,2])
		sb = Number data.inputs.sb
		if sb is 0 then Xb = 1000*std+mu
		else
			if (typeof data.inputs.b is "undefined") then data.inputs.b = mM.alea.real({min:a+1, max:100})
			b = Number data.inputs.b
			Xb = Math.floor(b*2*std)/100+mu
			ens = "#{ens} #{symbs[sb]} #{numToStr(Xb,2)}"
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>La variable aléatoire $X$ suit la <b>loi normale</b> de moyenne $\\mu = #{mu}$ et d'écart-type $\\sigma = #{std}$.</p><p><b>Remarque :</b> on note $\\mathcal{N}(#{mu};#{std})$ cette loi.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Calculs de probabilités"
				liste:[{
					tag:"$p(#{ens})$"
					name:"pX"
					description:"Valeur à 0,01 près"
					good: mM.repartition.gaussian {min:Xa, max:Xb}, { moy:mu, std:std }
					large:true
					arrondi:-2
				}]
				aide: oHelp.proba.binomiale.calculette
			}
		]
	tex: (data) ->
		symbs = ["","<","\\leqslant"]
		if not isArray(data) then data = [ data ]
		its = []
		for itData in data
			std = Number itData.inputs.std
			mu = Number itData.inputs.mu
			sa = Number itData.inputs.sa
			if sa is 0 then ens = "X"
			else
				a = Number itData.inputs.a
				Xa = Math.floor(a*2*std)/100+mu
				ens = "#{numToStr(Xa,2)} #{symbs[sa]} X"
			sb = Number itData.inputs.sb
			if sb isnt 0
				b = Number itData.inputs.b
				Xb = Math.floor(b*2*std)/100+mu
				ens = "#{ens} #{symbs[sb]} #{numToStr(Xb,2)}"
			its.push "La variable $X$ suit la loi normale de paramètres $\\mu = #{itData.inputs.mu}$ et $\\sigma = #{itData.inputs.std}$, notée $\\mathcal{N}(#{itData.inputs.mu};#{itData.inputs.std})$. \\\\Donnez $p(#{ens})$"
		if its.length > 1 then [{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					items: its
					large:false
				}
			}]
		else [{
				title:@title
				content:Handlebars.templates["tex_plain"] {
					content: its[0]
					large:false
				}
			}]
