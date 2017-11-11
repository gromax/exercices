
today = () ->
	d= new Date()
	d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate()
thisTime = () ->
	d= new Date()
	d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate()+" "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds()

pushUrlInHistory = (url) ->
	if (url isnt "") and (url isnt "#")
		Controller.load url
		history.pushState({}, "", url)

formToObject = (theArray) ->
	out = {}
	out[item.name] = item.value for item in theArray
	out

closeModal = () -> $("#modalContainer").modal "hide"

currentDate = (francais=false)->
	date = new Date()
	day = String date.getDate()
	if day.length is 1 then day = "0"+day
	month = String(date.getMonth()+1)
	if month.length is 1 then month = "0"+month
	if francais then "#{day}/#{month}/#{date.getFullYear()}"
	else "#{date.getFullYear()}-#{month}-#{day}"

###
Un exemple
		emailPattern = /// ^ #begin of line
			([\w.-]+)         #one or more letters, numbers, _ . or -
			@                 #followed by an @ sign
			([\w.-]+)         #then one or more letters, numbers, _ . or -
			\.                #followed by a period
			([a-zA-Z.]{2,6})  #followed by 2 to 6 letters or periods
			$ ///i            #end of line and ignore case
###

class @Controller
	@lastTime:null
	@uLog:null
	@showMessages:true
	@divIdCounter:0
	@routes:[]
	@initPage: (local=false) ->
		@uLog = new MLog();
		uri = window.location.hash
		$(document).on("click", "a, area", ()->
			pushUrlInHistory $(@).attr("href")
			return false
		)
		$(window).on "popstate", () ->
			Controller.load location.href
		jQuery.extend jQuery.validator.messages, {
			required: "Ce champ est requis.",
			email: "Entrez un email valide.",
			maxlength: jQuery.validator.format("{0} caractéres maximum"),
			minlength: jQuery.validator.format("{0} caractéres minimum."),
			equalTo: "Les mots de passent sont différents.",
			number: "Entrez un nombre"
		}
		unless local
			@menuLog = new VLogMenu { container:"#menu-droite", links:{ classe:"eleves-de-la-classe:"} }
			@uLog.on { type:"change", forever:true, obj:@menuLog, cb:(menu,user)->
				menu.display()
				Controller.initRoutes user
			}
		@uLog.on { type:"init", obj:uri, cb:(uri,user)->
			Controller.initRoutes user
			Controller.load uri
		}
		@uLog.setLocal(local)
		@uLog.init(local)
		# Quand on parcours les pages, il n'y a pas toujours de rechargement de données et donc
		# pas d'accès serveur qui remettrait le lastTime du serveur à jour
		# Donc, à chaque load de page, on actualise le lastTime côté client et quand ce lastTime
		# dépasse 60min, on met à jour le lastTime du serveur
		# A vrai dire, je ne suis pas sûr que cette fonctionnalité soit très utile
		@uLog.timeOut()
	@initRoutes: (user) ->
		switch
			when user.isAdmin then @routes = (item for item in routes when item.admin is true)
			when user.isProf then @routes = (item for item in routes when item.prof is true)
			when user.isEleve then @routes = (item for item in routes when item.eleve is true)
			when user.local then @routes = (item for item in routes when item.local is true)
			else @routes = (item for item in routes when item.off is true)
	@defaultView: () ->
		@setAriane()
		new VHome {}
	@load: (uri) ->
		i = uri.indexOf("#")
		if i is -1 then uri = ""
		else uri = uri.slice(i+1,uri.length)
		routeFound = false
		for route in @routes
			m = uri.match route.regex
			if m
				route.exec?.apply(@,[m])
				routeFound = true
				break
		if (uri.toLowerCase() isnt "deconnexion")
			@uLog?.timeOut()
		unless routeFound then @defaultView()
	@errorMessagesList: (liste, entete, glyph) ->
		if liste?.length >0
			for message in liste
				if message.success then _type = "success"
				else _type = "error"
				Controller.notyMessage entete+message.message, _type, glyph
	@notyMessage: (text, type, glyph) ->
		if @showMessages
			# Type possibles : alert (bleu) ou warning, info, success, error
			if typeof text isnt "string" then text = type
			if glyph? then text = "<span class='glyphicon "+glyph+"'></span> "+text
			noty({
				layout: 'topLeft',
				theme: 'bootstrapTheme',
				type: type,
				text: text,
				animation: {
					open: 'animated bounceInUp', # jQuery animate function property object
					close: 'animated bounceOutLeft', # jQuery animate function property object
					easing: 'swing', # easing
					speed: 500 # opening & closing animation speed
				}
			})
	@setAriane: (list) ->
		$("ol[name='ariane']").html Handlebars.templates.ariane( {fils:list} )

