
Exercice.liste.push
	id:51
	title:"Loi uniforme"
	description:"Calculer des probabilités avec la loi uniforme."
	keyWords:["probabilités","uniforme","TSTL"]
	options: {
		a:{ tag:"Calcul $E(X)$" , options:["Oui", "Non"] , def:0 }
		b:{ tag:"Calcul $\\sigma(X)$" , options:["Oui", "Non"] , def:0 }
	}
	init: (data) ->
		if (typeof data.inputs.Xmin is "undefined") then data.inputs.Xmin = mM.alea.real({min:-5, max:20})
		Xmin = Number data.inputs.Xmin
		if (typeof data.inputs.Xmax is "undefined") then data.inputs.Xmax = mM.alea.real({min:Xmin+10, max:100})
		Xmax = Number data.inputs.Xmax
		# Symbole d'inégalité à gauche
		symbs = ["","<","\\leqslant"]
		if (typeof data.inputs.sa is "undefined") then data.inputs.sa = mM.alea.real [0,1,2]
		sa = Number data.inputs.sa
		if sa is 0
			a = Xmin
			ens = "X"
		else
			if (typeof data.inputs.a is "undefined") then data.inputs.a = mM.alea.real({min:Xmin, max:Xmax-1})
			a = Number data.inputs.a
			ens = "#{a} #{symbs[sa]} X"
		if (typeof data.inputs.sb is "undefined")
			if sa is 0 then data.inputs.sb = mM.alea.real([1,2])
			else data.inputs.sb = mM.alea.real([0,1,2])
		sb = Number data.inputs.sb
		if sb is 0 then b = Xmax
		else
			if (typeof data.inputs.b is "undefined") then data.inputs.b = mM.alea.real({min:a+1, max:Xmax})
			b = Number data.inputs.b
			ens = "#{ens} #{symbs[sb]} #{b}"
		liste = [{
			tag:"$p(#{ens})$"
			name:"pX"
			description:"Valeur à 0,01 près"
			good:(b-a)/(Xmax-Xmin)
			params:{arrondi:-2}
		}]
		if data.options.a.value is 0 then liste.push {
			tag:"$E(X)$"
			name:"E"
			description:"Espérance à 0,01 près"
			good:(Xmin+Xmax)/2
			params:{arrondi:-2}
		}
		if data.options.b.value is 0 then liste.push {
			tag:"$\\sigma(X)$"
			name:"sig"
			description:"Ecart-type à 0,01 près"
			good:(Xmax-Xmin)/Math.sqrt(12)
			params:{arrondi:-2}
		}

		[
			new BEnonce {zones:[{body:"enonce", html:"<p>La variable aléatoire $X$ suit la <b>loi uniforme</b> sur $[#{Xmin};#{Xmax}]$.</p><p><b>Remarque :</b> on note parfois $\\mathcal{U}([#{Xmin};#{Xmax}])$ cette loi.</p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Calculs de probabilités"
				liste:liste
				aide: oHelp.proba.binomiale.calculette
			}
		]
	tex: (data, slide) ->
		symbs = ["","<","\\leqslant"]
		if not isArray(data) then data = [ data ]
		its=[]
		for itData in data
			sa = Number itData.inputs.sa
			if sa is 0 then ens = "X"
			else
				a = Number itData.inputs.a
				ens = "#{a} #{symbs[sa]} X"
			sb = Number itData.inputs.sb
			if sb isnt 0
				b = Number itData.inputs.b
				ens = "#{ens} #{symbs[sb]} #{b}"
			if (itData.options.a isnt 0) or (itData.options.b isnt 0)
				itsQuest = ["Donnez $p(#{ens})$"]
				if itData.options.a isnt 0 then itsQuest.push "Donnez $E(X)$ à $0,01$ près."
				if itData.options.b isnt 0 then itsQuest.push "Donnez $\\sigma(X)$ à $0,01$ près."
				its.push Handlebars.templates["tex_enumerate"] {
					pre:"La variable $X$ suit la loi uniforme sur $[#{itData.inputs.Xmin};#{itData.inputs.Xmax}]$."
					items: itsQuest
				}
			else its.push """La variable $X$ suit la loi uniforme sur $[#{itData.inputs.Xmin};#{itData.inputs.Xmax}]$.

			Donnez $p(#{ens})$"""
		if its.length > 1 then [{
				title:@title
				content:Handlebars.templates["tex_enumerate"] {
					items: its
					numero:"1)"
					large:slide is true
				}
			}]
		else [{
				title:@title
				content:Handlebars.templates["tex_plain"] {
					content: its[0]
					large:slide is true
				}
			}]

