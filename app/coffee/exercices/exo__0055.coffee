
Exercice.liste.push
	id:55
	title:"Limites de fonctions"
	description:"Déterminer la limite en $\\pm\\infty$ ou $x=a$ pour différents types de fonctions."
	keyWords:["limite","fonction","analyse","TSTL","BTS"]
	options: {
	}
	init: (data) ->
		# Voici les types de fonctions envisagées :
		# Un polynôme quelconque en +- infini
		# Une fonction rationnelle quelconque en +- infini
		if typeof data.inputs.d isnt "undefined"
			d = data.inputs.d.split(";")
			# d est un tableau contenant :
			# La valeur de x où on prend la limite, en tex
			# L'expression de la fonction, en tex
			# Le string de la limite (la réponse)
			x_tex = d[0]
			expr_tex = d[1]
			l = mM.parse d[2]
		else
			# Pour l'instant, je me contente d'une version de l'exercice avec des fonctions rationnelles
			# on va envisager 2 cas :
			switch mM.alea.real [1,2]
				when 1
					# La limite sera infinie
					deg_num = mM.alea.real [1,2,3]
					deg_den = mM.alea.real [1,2,3]
					dom_num = mM.alea.real { min:1, max:9 }
					dom_den = mM.alea.real { min:1, max:9 }
					den = mM.alea.poly { degre:deg_den, values:{min:0, max:9, sign:true}, coeffDom:dom_den }
					num = mM.alea.poly { degre:deg_num, values:{min:0, max:9, sign:true}, coeffDom:dom_num }
					f_list = [num, den, "/"]
					switch
						when deg_den > deg_num then l_list = [ 0 ]
						when deg_den < deg_num then l_list = [ "∞" ]
						else l_list = [ dom_num, dom_den, "/" ]
					if mM.alea.dice(1,2)
						f_list.push "*-"
						l_list.push "*-"
					x_tex = "+\\infty"
				when 2
					# Limite infinie en un réel, fonction type poly + num / (x-x0)
					x0 = mM.alea.real { min:-10, max:10}
					poly = mM.alea.poly { degre:{min:0, max:2}, values:{min:0, max:9, sign:true} }
					num = mM.alea.poly { degre:{min:0, max:2}, values:{min:0, max:9, sign:true}, coeffDom:1}
					den = mM.exec ["x", x0, "-"], { simplify:true }
					f_list = [ poly, num, "x", den, "/"]
					l_list = [ "∞" ]
					if mM.float(num,{x:x0})<0 then l_list.push "*-"
					if mM.alea.dice(1,2)
						f_list.push "-"
						l_list.push "*-"
					else f_list.push "+"
					x_tex = "#{x0}^{+}"
			l = mM.exec l_list, { simplify:true }
			f = mM.exec f_list
			expr_tex = f.tex()
			data.inputs.d = [ x_tex, expr_tex, String l ].join(";")
		data.tex = {
			x: x_tex
			expression : expr_tex
		}
		[
			new BEnonce {
				title:"Énoncé"
				zones:[
					{
						body:"enonce"
						html:"<p>Donnez la limite $\\displaystyle \\lim_{x \\to #{x_tex}} #{expr_tex}$</p>"
					}
				]
			}
			new BListe {
				title: "Limite"
				data:data
				bareme:100
				liste: [
					tag:"Limite"
					name:"l"
					description:"Limite"
					good:l
					large:true
				]
				touches:["infini"]
			}
		]
	tex: (data) ->
		if not isArray(data) then data = [ data ]
		{
			title:@title
			content:Handlebars.templates["tex_enumerate"] {
				pre: "Donnez les limites suivantes :"
				items: ("$\\displaystyle \\lim_{x \\to #{item.tex.x}} #{item.tex.expression}$" for item in data)
				large:false
			}
		}


