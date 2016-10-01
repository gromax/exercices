
# Tableau de variation
# uses SVG
class @TabVar
	constructor: (x_list, params) ->
		@config = { espace_gauche:100, marge:20, margeArrow:15, espace_entre_valeurs:100, hauteur_ligne:40, x_tag:"$x$", color:"#000000", texColor:"black" }
		if (typeof params is "object") and params isnt null
			@config[key] = params[key] for key of params
		@x_list = x_list
		@x_tag = @config.x_tag
		@lines = []
		@paper = null	# Objet SVG permettant l'affichage
	linesNumber : () ->
		n = 1 # compte pour la ligne d'entête
		n += ligne.hauteur for ligne in @lines
		n
	addVarLine: (line, params) ->
		# -/val
		# +/val
		# R
		# -D/val
		# +D/val
		# D-/val
		# D+/val
		# -D-/val/val
		# -D+/val/val
		# +D-/val/val
		# +D+/val/val
		config = { h:3, tag:"$f$" }
		if (typeof params is "object") and params isnt null
			config[key] = params[key] for key of params
		if typeof line is "string" then line=line.split(',')
		if not(typeIsArray(line)) then return
		line.push('?') while line.length<@x_list.length # On s'assure une longueur minimum
		line.pop() while line.length>@x_list.length # On s'assure d'une longueur maximum
		out = []
		for item in line
			tab = item.split("/")
			tab.push "?" while tab.length<2
			switch
				when tab[0] is "-" then out.push {pos:"bottom", tag:tab[1]}
				when tab[0] is "+" then out.push {pos:"top", tag:tab[1]}
				when tab[0] is "R" then out.push { type: "none" }
				when tab[0] is "-D" then out.push { type:"forbidden", leftPos:"bottom", leftTag:tab[1] }
				when tab[0] is "+D" then out.push { type:"forbidden", leftPos:"top", leftTag:tab[1] }
				when tab[0] is "D-" then out.push { type:"forbidden", rightPos:"bottom", rightTag:tab[1] }
				when tab[0] is "D+" then out.push { type:"forbidden", rightPos:"top", rightTag:tab[1] }
				when tab[0] is "-D-" then out.push { type:"forbidden", leftPos:"bottom", leftTag:tab[1], rightPos:"bottom", rightTag:tab[2] }
				when tab[0] is "-D+" then out.push { type:"forbidden", leftPos:"bottom", leftTag:tab[1], rightPos:"top", rightTag:tab[2] }
				when tab[0] is "+D-" then out.push { type:"forbidden", leftPos:"top", leftTag:tab[1], rightPos:"bottom", rightTag:tab[2] }
				when tab[0] is "+D+" then out.push { type:"forbidden", leftPos:"top", leftTag:tab[1], rightPos:"top", rightTag:tab[2] }
		@lines.push {type:"var", tag:config.tag, str:line.join(), values:out, hauteur:Math.max(config.h,3)}
		@
	addSignLine: (line, params) ->
		# line est un texte qui a la forme z,+,z
		# Sur les rangs pairs (zones) :  +, -, espace, h = zone interdite, ? = inconnu
		# Sur les rangs impairs (valeurs) : d = double-barre, z = 0, t = pointillé, espace, ? = inconnu
		config = { h:1, tag:"$f(x)$" }
		if (typeof params is "object") and params isnt null
			config[key] = params[key] for key of params
		if typeof line is "string" then line=line.split(',')
		if not(typeIsArray(line)) then return
		line.push('?') while line.length<2*@x_list.length-1 # On s'assure une longueur minimum
		line.pop() while line.length>2*@x_list.length-1 # On s'assure d'une longueur maximum
		@lines.push {type:"sign", sign:true, tag:config.tag, values:line, hauteur:Math.max(config.h,1)}
		@
	tex: (params) ->
		entetes = ("#{line.tag}/#{line.hauteur/2}" for line in @lines)
		entetes.unshift "#{@x_tag}/1"
		config = { lgt:1, espcl:1.5, lw:"1pt", entetes:entetes.join(), lines:@lines, x_list:@x_list.join(), color:@config.texColor }
		if (typeof params is "object") and params isnt null
			config[key] = params[key] for key of params
		Handlebars.templates["tex_tab"] config
	render: (div) ->
		longueur = @config.espace_gauche+(@x_list.length-1)*@config.espace_entre_valeurs+2*@config.marge
		hauteur = @linesNumber() * @config.hauteur_ligne
		if typeof div isnt "undefined"
			# si on donne le div, le paper est réinistialisé
			if (div instanceof jQuery) or ('jquery' in Object(div)) then div=div.get(0)
			@paper = new SVG(div, longueur, hauteur)
		else if @paper is null then return
		@paper.rect(0, 0, longueur, @config.hauteur_ligne, @config.color)		# Rectangle des x
		@paper.rect(0, 0, @config.espace_gauche, @config.hauteur_ligne, @config.color)	# Rectangle entête des x
		@paper.text(@config.x_tag, @config.espace_gauche/2, @config.hauteur_ligne/2, @config.espace_gauche, @config.hauteur_ligne, "center", "center")
		x0 = @config.espace_gauche+@config.marge # Origine x pour les valeurs du tableau
		for x,i in @x_list
			@paper.text(x, x0+@config.espace_entre_valeurs*i, @config.hauteur_ligne/2, @config.espace_entre_valeurs,@config.hauteur_ligne,"center","center")
			###
			switch
				when i is 0 then @paper.text(x, x0+@config.espace_entre_valeurs*i, @config.hauteur_ligne/2, @config.espace_entre_valeurs,@config.hauteur_ligne, "left", "center", {"padding-left":"5px"})
				when i is @x_list.length-1 then @paper.text(x, x0+@config.espace_entre_valeurs*i, @config.hauteur_ligne/2, @config.espace_entre_valeurs,@config.hauteur_ligne, "right", "center", {"padding-right":"5px"})
				else @paper.text(x, x0+@config.espace_entre_valeurs*i, @config.hauteur_ligne/2, @config.espace_entre_valeurs,@config.hauteur_ligne,"center","center")
			###
		lineY = 1	# Origine Y (en nombre de lignes) de la nouvelle ligne à afficher
		for line in @lines
			if line.type is "var" then @renderVarLine(line,lineY)
			else if line.type is "sign" then @renderSignLine(line,lineY)
			lineY += line.hauteur
		@
	renderSignLine: (line,lineY) ->
		d = @config.espace_entre_valeurs
		h0 = @config.hauteur_ligne
		h = line.hauteur*h0
		@paper.rect(0, lineY*h0, @config.espace_gauche+(@x_list.length-1)*d+2*@config.marge, line.hauteur*h0, @config.color) # Rectangle de la liste
		x0=@config.espace_gauche + @config.marge
		y0= (lineY + line.hauteur/2)*@config.hauteur_ligne # Centre vertical de la linge

		@paper.rect(0, lineY*h0, @config.espace_gauche, line.hauteur*h0, @config.color) # Rectangle de l'entête
		@paper.text(line.tag, @config.espace_gauche/2, y0, x0, line.hauteur*h0, "center", "center")
		for item,j in line.values
			i = j/2 # Position x en nombre de cases
			if j%2 is 0
				# En face de la valeur i
				switch
					when item is "z"
						# ligne avec zéro
						@paper.line(x0+i*d,lineY*h0,x0+i*d,(lineY+line.hauteur)*h0,{dash:'5,5', width:.5})
						@paper.text("$0$",x0+d*i, y0, d,h0, "center", "center")
					when item is "d"
						# double barre
						@paper.line(x0+i*d-2,lineY*h0,x0+i*d-2,(lineY+line.hauteur)*h0)
						@paper.line(x0+i*d+2,lineY*h0,x0+i*d+2,(lineY+line.hauteur)*h0)
					when item is "t"
						# simple ligne
						@paper.line(x0+i*d,lineY*h0,x0+i*d,(lineY+line.hauteur)*h0,{dash:'5,5', width:.5})
			else
				# En face d'une zone
				switch
					when (item is "+") or (item is "-")
						@paper.text("$"+item+"$",x0+d*i, y0, d,h0, "center", "center")
				# Sinon, pour l'instant, rien
	renderVarLine: (line,lineY) ->
		h = line.hauteur*@config.hauteur_ligne
		@paper.rect(0, lineY*@config.hauteur_ligne, @config.espace_gauche+(@x_list.length-1)*@config.espace_entre_valeurs+2*@config.marge, h, @config.color) # Rectangle de la liste
		x0=@config.espace_gauche + @config.marge
		d=@config.espace_entre_valeurs
		@paper.rect(0, lineY*@config.hauteur_ligne, @config.espace_gauche, h, @config.color) # Rectangle de l'entête
		@paper.text(line.tag, @config.espace_gauche/2, (lineY+line.hauteur/2)*@config.hauteur_ligne, x0, h, "center", "center")
		arrowPath = [] # Chemin des flèches
		for item,i in line.values
			switch
				when typeof item.type is "undefined"
					# Cas normal
					arrowPath.push @renderTabVarValueTag(item.tag, "center", item.pos, i, lineY, line.hauteur)
					if not ( (item?.no_vertical_line is true) or (i is 0) or (i is line.values.length-1))
						# Tracé d'une ligne pointillée verticale
						@paper.line(x0+i*d,lineY*@config.hauteur_ligne,x0+i*d,lineY*@config.hauteur_ligne+h,{dash:'5,5', width:.5})
				#when item.type is "value"
					# On écrit une valeur sans interrompre la flèche
				when item.type is "forbidden"
					if typeof item.leftTag isnt "undefined"
						arrowPath.push @renderTabVarValueTag(item.leftTag, "right", item.leftPos, i, lineY, line.hauteur)
					arrowPath.push {break_path:true}
					if typeof item.rightTag isnt "undefined"
						arrowPath.push @renderTabVarValueTag(item.rightTag, "left", item.rightPos, i, lineY, line.hauteur)
					# Double ligne verticale
					@paper.line(x0+i*d-2,lineY*@config.hauteur_ligne,x0+i*d-2,lineY*@config.hauteur_ligne+h, {color:@config.color})
					@paper.line(x0+i*d+2,lineY*@config.hauteur_ligne,x0+i*d+2,lineY*@config.hauteur_ligne+h, {color:@config.color})
		# On peut maintenant gérer le path
		if arrowPath.length>1
			for i in [0..arrowPath.length-2]
				@renderArrow(arrowPath[i],arrowPath[i+1])
	renderTabVarValueTag: (tag, align, valign, rang, line, h) ->
		switch
			when align is "left" then css = {"padding-left":"5px"}
			when align is "right" then css = {"padding-right":"5px"}
			else css = undefined
		switch
			when valign is "bottom" then y = h
			when valign is "top" then y=0
			when valign is "center" then y=h/2
			else
				y=valign*h
				valign = "center"
		@paper.text(tag, @config.espace_gauche+@config.marge+@config.espace_entre_valeurs*rang, (line+y)*@config.hauteur_ligne, @config.espace_entre_valeurs,@config.hauteur_ligne, align, valign, css)
		# On retourne un objet pour le arrowPath
		{ x:@config.espace_gauche+@config.marge+@config.espace_entre_valeurs*rang, y:(y*(h-1)/h+1/2+line)*@config.hauteur_ligne, rang:rang, break_path:false}
	renderArrow: (it1,it2)->
		if not(it1.break_path or it2.break_path)
			coeff = (it2.y-it1.y)/(it2.x-it1.x)
			@paper.arrow(it1.x+@config.margeArrow,it1.y+coeff*@config.margeArrow,it2.x-@config.margeArrow,it2.y-coeff*@config.margeArrow, {color:@config.color})
