
# Helper SVG
class @SVG
	constructor: (div, width, height) ->
		@node = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
		@node.style.width = width+"px"
		@node.style.height = height+"px"
		#@node.style.overflow = 'visible';
		#@node.style.position = 'absolute';
		@node.setAttribute('version', '1.1')
		@node.setAttribute('xmlns', 'http://www.w3.org/2000/svg')
		div.appendChild(@node)
		# Création d'un marker pour les flèches
		defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs')
		marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker')
		marker.setAttribute('id', 'Triangle')
		marker.setAttribute('viewBox', '0 0 10 10')
		marker.setAttribute('refX', '0')
		marker.setAttribute('refY', '5')
		marker.setAttribute('markerUnits', 'strokeWidth')
		marker.setAttribute('markerWidth', '4')
		marker.setAttribute('markerHeight', '3')
		marker.setAttribute('orient', 'auto')
		path = document.createElementNS('http://www.w3.org/2000/svg', 'path')
		marker.appendChild(path)
		path.setAttribute('d', 'M 0 0 L 10 5 L 0 10 z')
		@node.appendChild(defs)
		defs.appendChild(marker)
	rect: (x,y,width,height,color="#000000") ->
		obj = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
		obj.setAttribute('x', x)
		obj.setAttribute('y', y)
		obj.setAttribute('width', width)
		obj.setAttribute('height', height)
		obj.setAttribute('stroke', color)
		obj.setAttribute('stroke-width', 3)
		obj.setAttribute('fill', 'white')
		@node.appendChild(obj)
	text: (text,x,y,width,height,align,valign,css) ->
		newNode = document.createElementNS("http://www.w3.org/2000/svg", 'foreignObject') #Create a rect in SVG's namespace
		switch
			when align is "right" then x = x-width
			when align is "center" then x = x-width/2
			# À défaut, alignement à gauche
		switch
			when valign is "center"
				$(newNode).css("line-height",height+"px")
				y=y-height/2
			when valign is "bottom"
				$(newNode).css({"line-height":height+"px","vertical-align":"text-bottom"})
				y=y-height
			# à défaut, ce sera aligné en haut
			else
				$(newNode).css("line-height",height+"px")
		newNode.setAttribute("x",x) # Set rect data
		newNode.setAttribute("y",y) #Set rect data
		newNode.setAttribute("width",String(width)) # Set rect data
		newNode.setAttribute("height",String(height)) # Set rect data
		obj = $(newNode)
		obj.append(text)
		obj.css("text-align",align)
		if typeof css isnt "undefined" then obj.css(css)
		@node.appendChild(newNode)
	line: (x1,y1,x2,y2,params) ->
		defaultParams = {color:'#000000', width:2}
		if typeof params is "object"
			defaultParams[key] = params[key] for key of params
		obj = document.createElementNS('http://www.w3.org/2000/svg', 'line')
		obj.setAttribute('x1', x1)
		obj.setAttribute('y1', y1)
		obj.setAttribute('x2', x2)
		obj.setAttribute('y2', y2)
		obj.setAttribute('stroke', defaultParams.color)
		obj.setAttribute('stroke-width', defaultParams.width)
		if typeof defaultParams.dash isnt "undefined" then obj.setAttribute('stroke-dasharray', defaultParams.dash)
		if typeof defaultParams.opacity isnt "undefined" then obj.setAttribute('opactity', defaultParams.opacity)
		@node.appendChild(obj);
	arrow: (x1,y1,x2,y2,params) ->
		defaultParams = {color:'#000000', width:2}
		if typeof params is "object"
			defaultParams[key] = params[key] for key of params
		obj = document.createElementNS('http://www.w3.org/2000/svg', 'line')
		obj.setAttribute('x1', x1)
		obj.setAttribute('y1', y1)
		obj.setAttribute('x2', x2)
		obj.setAttribute('y2', y2)
		obj.setAttribute('stroke', defaultParams.color)
		obj.setAttribute('stroke-width', defaultParams.width)
		obj.setAttribute('marker-end', 'url(#Triangle)')
		@node.appendChild(obj);
