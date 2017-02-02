
Exercice.liste.push
	id:56
	title:"Limite et asymptote"
	description:"Une limite est donnée, il faut en déduire l'existence, ou non, d'une asymptote."
	keyWords:["limites, TSTL, BTS, équation, droite, asymptote"]
	options: null
	init: (data) ->
		# On génère une limite. Soit c'est x, soit c'est y
		if typeof data.inputs.i isnt "undefined"
			i = data.inputs.i.split(":")
			c = i[0] ? "x"
			v = i[1] ? mM.alea.real { min:-10, max:10 }
		else
			c = mM.alea.in ["x", "y"]
			v = mM.alea.real { min:-10, max:10 }
		data.inputs.i = "#{c}:#{v}"
		if c is "x"
			x_tex = "#{v}^{#{mM.alea.in(['+','-'])}}"
			y_tex = "#{mM.alea.in(['+','-'])}\\infty"
			good = mM.equation ["x"], v
		else
			x_tex = "#{mM.alea.in(['+','-'])}\\infty"
			y_tex = "#{v}"
			good = mM.equation ["y"], v
		data.tex = { x:x_tex, y:y_tex }
		[
			new BEnonce {
				title:"Énoncé"
				zones:[
					{
						body:"enonce "
						html:"<p>On donne $\\displaystyle \\lim_{x \\to #{x_tex}} f(x) = #{y_tex}$</p><p>Donnez l'équation de l'asymptote correspondante."
					}
				]
			}
			new BEquations {
				title: "Équation"
				data:data
				bareme:100
				equations: [ good ]
			}
		]
	tex: (data, slide) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Donnez les équations des asymptotes correspondant aux limites suivantes :"
				items: ("$\\displaystyle \\lim_{x \\to #{item.tex.x}} f(x) = #{item.tex.y}$" for item in data)
				large:slide is true
			}
		}


