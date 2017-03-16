
today = () ->
	d= new Date()
	d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate()
thisTime = () ->
	d= new Date()
	d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate()+" "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds()

closeModal = () -> $("#modalContainer").modal "hide"

pushUrlInHistory = (url) ->
	if (url isnt "") and (url isnt "#")
		Controller.load url
		history.pushState({}, "", url)

formToObject = (theArray) ->
	out = {}
	out[item.name] = item.value for item in theArray
	out

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
		@lastTime = (new Date()).getTime()
	@initRoutes: (user) ->
		switch
			when user.isAdmin then @routes = [
				{# deconnexion
					regex:/// ^deconnexion$ ///i
					exec:(m)->
						Controller.uLog.deconnexion { cb: ()-> new VHome {} }
						@setAriane()
				}
				{# comptes
					regex:/// ^comptes$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des utilisateurs"}]
						new VUsersList {}
				}
				{ #user:id/edit - aussi prof
					regex:/// ^utilisateur:([0-9]+)/edit$ ///i
					exec:(m)->
						idUser = Number m[1]
						user=Controller.uLog.users.get idUser
						if user?
							@setAriane [
								{link:"comptes", text:"Liste des utilisateurs"}
								{text:"Modification de l'utilisateur : #{user.nom} #{user.prenom}"}
							]
							new VUserMod {
								item:user
								container:"#mainContent"
								links: { cancel:"comptes" }
							}
				}
				{ #mon-compte/edit - aussi prof
					regex:/// ^mon-compte/edit$ ///i
					exec:(m)->
						@setAriane [
							{text:"Modification de mon compte"}
						]
						new VUserMod {
							item:Controller.uLog
							container:"#mainContent"
							links: { cancel:"Home" }
						}
				}
				{# classes
					regex:/// ^classes$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des classes"}]
						new VClassesList { links:{ classe:"eleves-de-la-classe:"} }
				}
				{# classes/add - aussi prof
					regex:/// ^classes/add$ ///i
					exec:(m)->
						@setAriane [
							{link:"classes", text:"Liste des classes"}
							{text:"Création d'une classe"}
						]
						new VClasseMod {
							container:"#mainContent"
							links: { cancel:"classes" }
						}
				}
				{ # classe:id/edit - aussi prof
					regex:/// ^classe:([0-9]+)/edit$ ///i
					exec:(m)->
						idClasse = Number m[1]
						classe=Controller.uLog.classes.get idClasse
						if classe?
							@setAriane [
								{link:"classes", text:"Liste des classes"}
								{text:"Modification de la classe : "+classe.nom}
							]
							new VClasseMod {
								item:classe
								container:"#mainContent"
								links: { cancel:"classes" }
							}
				}
				{ # exercices - aussi prof et élève et local
					regex:/// ^exercices$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des exercices"}]
						new VExercicesList {}
				}
				{ # tester-exercice:id - aussi prof et élève et local
					regex:/// ^tester-exercice:([0-9]+)$ ///i
					exec:(m)->
						@setAriane [
							{link:"exercices", text:"Liste des exercices"}
							{text:"Test d'un exerice"}
						]
						new VExercice { idE:Number m[1] }
				}
				{ # devoirs
					regex:/// ^devoirs$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des devoirs"}]
						new VFichesList { links:{devoir:"devoir:", notes:"notes-devoir:"} }
				}
				{ # devoirs/add - aussi prof
					regex:/// ^devoirs/add$ ///i
					exec:(m)->
						@setAriane [
							{link:"devoirs", text:"Liste des devoirs"}
							{text:"Création d'un devoir"}
						]
						Controller.uLog.fiches.on {type:"add", obj:@, cb:(view, item)->
							pushUrlInHistory "#devoirs"
							Controller.load "#devoirs"
						}
						new VFicheMod {
							container: "#mainContent"
							links: { cancel:"devoirs" }
						}
				}

				{ # devoir:id - aussi prof
					regex:/// ^devoir:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{text:"Devoir : #{fiche.nom}"}
							]
							new VList_aEF {
								fiche: fiche
								links: { direct:null, notes:"notes-devoir:", test:"devoir:#{fiche.id}/tester-exercice:"}
							}
						}
				}
				{ # devoir:id/edit - aussi prof
					regex:/// ^devoir:([0-9]+)/edit$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{text:"Modification du devoir : #{fiche.nom}"}
							]
							new VFicheMod {
								item:fiche
								container: "#mainContent"
								links: { cancel:"devoirs" }
							}
						}
				}
				{ # devoir:id/exam - aussi prof
					regex:/// ^devoir:([0-9]+)/exams$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{text:"Examens du devoir : #{fiche.nom}"}
							]
							new VExamsList {
								fiche: fiche
								links: { test:"devoir:#{m[1]}/exam:", edit:"devoir:#{m[1]}/exam:" }
							}
						}
				}
				{ # exam:id/edit - aussi prof
					regex:/// ^devoir:([0-9]+)/exam:([0-9]+)/edit$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							exam = fiche.exams.get(Number m[2])
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{m[1]}/exams", text:"Examens du devoir : #{fiche.nom}"}
								{text:"Modification de l'exam : #{exam?.nom}"}
							]
							new VExamMod {
								item:exam
								container: "#mainContent"
								links: { cancel:"devoir:#{m[1]}/exams" }
							}
						}
				}
				{ # devoir:id/exam:id/exo:id - aussi prof
					regex:/// ^devoir:([0-9]+)/exam:([0-9]+)/exo:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{fiche.id}/exams", text:"Examens du devoir : #{fiche.nom}"}
							]
							exam = fiche.exams.get(Number m[2])
							# On cherche l'exercice à afficher
							indice = Number m[3]
							examInfos = exam.getExo indice-1
							if examInfos isnt null
								if examInfos.next then linkNext = "devoir:#{m[1]}/exam:#{m[2]}/exo:#{indice+1}" else linkNext = null
								if examInfos.prev then linkPrev = "devoir:#{m[1]}/exam:#{m[2]}/exo:#{indice-1}" else linkPrev = null
								new VExercice { examInfos:examInfos, linkNext:linkNext, linkPrev:linkPrev, canModif:exam.locked is false }
						}
				}
				{ # devoir:id/ajout-exercice - aussi prof - Est-il encore d'actualité ???
					regex:/// ^devoir:([0-9]+)/ajout-exercice$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{text:"Devoir : #{fiche.nom}"}
							]
							new VList_aEF {
								fiche: fiche
								links: { direct:null, notes:"notes-devoir:", test:"devoir:#{fiche.id}/tester-exercice:"}
							}
						}
				}
				{ # devoir:id/tester-exercice:id - aussi prof
					regex:/// ^devoir:([0-9]+)/tester-exercice:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						aEF= Number m[2]
						fiche?.load { type:"load", obj:aEF, cb:(aEF,fiche)->
							if (oEF = fiche?.exercices?.get aEF)?
								Controller.setAriane [
									{link:"devoirs:", text:"Liste des devoirs"}
									{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
									{text:"Test d'un exerice"}
								]
								new VExercice { oEF:oEF }
						}
				}
				{ # notes-devoir:id - aussi prof (avec "vos devoirs")
					regex:/// ^notes-devoir:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
								{text:"Liste des élèves"}
							]
							new VList_aUF {
								filtre:{idFiche:fiche.id}
								showUser:true
								fiche:fiche
								canMod:true
								links: { direct:null, indirect:"notes-devoir:#{fiche.id}/eleve:"}
							}
						}
				}
				{ # notes-devoir:id/ajout-eleve - aussi prof (avec "vos devoirs")
					regex:/// ^notes-devoir:([0-9]+)/ajout-eleve$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { type:"load", cb:(fiche)->
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
								{link:"notes-devoir:#{m[1]}", text:"Liste des élèves"}
								{text:"Ajouter des élèves"}
							]
							new VUserChoice { fiche:fiche }
						}
				}
				{ # notes-devoir:id/eleve:id - aussi prof (avec "vos devoirs")
					# Liste des exercices pour un devoir et un élève (donc pour un aUF)
					# C'est un parcours depuis le devoir
					# Il est utile d'avoir tous les élèves du devoir afin de permettre un parcours entre élèves
					regex:/// ^notes-devoir:([0-9]+)/eleve:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { obj:Number(m[2]), cb:(aUF,fiche)->
							oUF = Controller.uLog.UFlist.get aUF
							eleve = oUF?.user()
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
								{link:"notes-devoir:#{fiche.id}", text:"Liste des élèves"}
								{text:"#{eleve?.prenom} #{eleve?.nom}"}
							]
							new VList_aEF {
								fiche:fiche
								aUF:aUF
								user:eleve
								links: { direct:"notes-devoir:#{fiche.id}/eleve:#{aUF}/exercice:", notes:"notes-devoir:", test:null }
							}
						}
				}
				{ # note-devoir:id/eleve:id/exercice:id - aussi prof (avec "vos devoirs")
					# Liste des notes pour un exercice donné dans un aUF
					# C'est un parcours depuis le devoir
					# Il est utile d'avoir tous les élèves du devoir afin de permettre un parcours entre élèves
					regex:/// ^notes-devoir:([0-9]+)/eleve:([0-9]+)/exercice:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { obj:{ aUF:Number(m[2]), aEF:Number(m[3]) }, cb:(p,fiche)->
							{ aUF, aEF } = p
							oUF = Controller.uLog.UFlist.get aUF
							eleve = oUF?.user()
							oEF = fiche.exercices?.get aEF
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
								{link:"notes-devoir:#{fiche.id}", text:"Liste des élèves"}
								{link:"notes-devoir:#{fiche.id}/eleve:#{aUF}", text:"#{eleve?.prenom} #{eleve?.nom}"}
								{text:"Exercice : #{oEF?.exercice.title}"}
							]
							new VNotesList {
								fiche:fiche
								exoFiche:oEF
								aUF:aUF
								filtre:{aEF:oEF?.id, aUF:aUF}
								user:eleve
								links:{ notes:"notes-devoir:#{fiche.id}/eleve:#{aUF}/note:" }
							}
						}
				}
				{ # note-devoir:id/eleve:id/note:id - aussi prof (avec "vos devoirs")
					# Une note dans un exercice dans un aUF
					# C'est un parcours depuis le devoir
					# Il est utile d'avoir tous les élèves du devoir afin de permettre un parcours entre élèves
					regex:/// ^notes-devoir:([0-9]+)/eleve:([0-9]+)/note:([0-9]+)$ ///i
					exec:(m)->
						fiche = Controller.uLog.fiches.get(Number m[1])
						fiche?.load { obj:{ aUF:Number(m[2]), idNote:Number(m[3]) }, cb:(p,user)->
							{ aUF, idNote } = p
							oUF = Controller.uLog.UFlist.get aUF
							user = oUF?.user()
							note=user?.notes().get idNote
							oEF = note?.exoFiche()
							Controller.setAriane [
								{link:"devoirs", text:"Liste des devoirs"}
								{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
								{link:"notes-devoir:#{fiche.id}", text:"Liste des élèves"}
								{link:"notes-devoir:#{fiche.id}/eleve:#{aUF}", text:"#{user?.prenom} #{user?.nom}"}
								{link:"notes-devoir:#{fiche.id}/eleve:#{aUF}/exercice:#{oEF?.id}", text:"Exercice : #{oEF?.exercice.title}"}
								{text:"Essai du #{note?.dateFr} à #{note?.hour}"}
							]
							new VExercice {
								oNote:note
								links:{notes:"notes-devoir:#{fiche.id}/eleve:#{aUF}/note:"}
							}
						}
				}
				{ # eleves-de-la-classe:id - aussi prof (avec "vos classes")
					regex:/// ^eleves-de-la-classe:([0-9]+)$ ///i
					exec:(m)->
						idClasse = Number m[1]
						classe=Controller.uLog.classes.get idClasse
						if classe?
							filtre = { idClasse:idClasse, rank:"Élève", classe:classe }
							Controller.uLog.users.setFilter filtre
							@setAriane [
								{link:"classes", text:"Liste des classes"}
								{text:"Liste des élèves de "+classe.nom}
							]
							new VUsersList { filtre: filtre, showClasses:false, showRanks:false }
				}
				{ # notes-eleve:id - aussi prof (avec "vos classes")
					# Liste des devoirs d'un élève, avec les notes
					regex:/// ^notes-eleve:([0-9]+)$ ///i
					exec:(m)->
						idUser = Number m[1]
						eleve=Controller.uLog.users.get idUser
						eleve?.load { cb:(user)->
							Controller.setAriane [
								{link:"comptes", text:"Liste des utilisateurs"}
								{text:"Notes de #{user.prenom} #{user.nom}"}
							]
							new VList_aUF {
								filtre:{idUser:user.id}
								showFiche:true
								user:user
								links:{ direct:"notes-eleve:#{user.id}/devoir:", indirect:null }
							}
						}
				}
				{ # notes-eleve:id/devoir:id - aussi prof (avec "vos élèves")
					# Liste des exercices pour un devoir et un élève (donc pour un aUF)
					# C'est un parcours depuis l'élève
					# Il est utile d'avoir tous les devoirs de l'élève afin de permettre un parcours entre devoirs
					regex:/// ^notes-eleve:([0-9]+)/devoir:([0-9]+)$ ///i
					exec:(m)->
						eleve=Controller.uLog.users.get Number m[1]
						eleve?.load { obj:Number(m[2]), cb:(aUF,user)->
							oUF = Controller.uLog.UFlist.get aUF
							Controller.setAriane [
								{link:"comptes", text:"Liste des utilisateurs"}
								{link:"notes-eleve:#{user.id}", text:"Notes de #{user.prenom} #{user.nom}"}
								{text:"Devoir : #{oUF?.fiche()?.nom}"}
							]
							new VList_aEF {
								fiche:oUF?.fiche()
								aUF:aUF
								user:user
								links:{ direct:"notes-eleve:#{user.id}/devoir:#{aUF}/exercice:", test:null, notes:"notes-devoir:" }
							}
						}
				}
				{ # notes-eleve:id/devoir:id/exercice:id - aussi prof (avec "vos élèves")
					# Liste des notes pour un exercice donné dans un aUF
					# C'est un parcours depuis l'élève
					# Il est utile d'avoir tous les devoirs de l'élève afin de permettre un parcours entre devoirs
					regex:/// ^notes-eleve:([0-9]+)/devoir:([0-9]+)/exercice:([0-9]+)$ ///i
					exec:(m)->
						idUser = Number m[1]
						eleve=Controller.uLog.users.get idUser
						eleve?.load { obj:{ aUF:Number(m[2]), aEF:Number(m[3]) }, cb:(p,user)->
							{ aUF, aEF } = p
							oUF = Controller.uLog.UFlist.get aUF
							fiche = oUF?.fiche()
							oEF = fiche?.exercices?.get aEF
							Controller.setAriane [
								{link:"comptes", text:"Liste des utilisateurs"}
								{link:"notes-eleve:#{user.id}", text:"Notes de #{user.prenom} #{user.nom}"}
								{link:"notes-eleve:#{user.id}/devoir:#{aUF}", text:"Devoir : #{fiche?.nom}"}
								{text:"Exercice : #{oEF?.exercice.title}"}
							]
							new VNotesList {
								fiche:fiche
								exoFiche:oEF
								aUF:aUF
								filtre:{aEF:oEF?.id, aUF:aUF}
								user:user
								links:{ notes:"notes-eleve:#{user.id}/devoir:#{aUF}/note:" }
							}
						}
				}
				{ # aussi prof (avec "vos élèves")
					# Une note dans un exercice dans un aUF
					# C'est un parcours depuis l'élève
					# Il est utile d'avoir tous les devoirs de l'élève afin de permettre un parcours entre devoirs
					regex:/// ^notes-eleve:([0-9]+)/devoir:([0-9]+)/note:([0-9]+)$ ///i
					exec:(m)->
						idUser = Number m[1]
						eleve=Controller.uLog.users.get idUser
						eleve?.load { obj:{ aUF:Number(m[2]), idNote:Number(m[3]) }, cb:(p,user)->
							{ aUF, idNote } = p
							oUF = Controller.uLog.UFlist.get aUF
							fiche = oUF?.fiche()
							note=user.notes().get idNote
							oEF = note?.exoFiche()
							Controller.setAriane [
								{link:"comptes", text:"Liste des utilisateurs"}
								{link:"notes-eleve:#{user.id}", text:"Notes de #{user.prenom} #{user.nom}"}
								{link:"notes-eleve:#{user.id}/devoir:#{aUF}", text:"Devoir : #{fiche?.nom}"}
								{link:"notes-eleve:#{user.id}/devoir:#{aUF}/exercice:#{oEF?.id}", text:"Exercice : #{oEF?.exercice.title}"}
								{text:"Essai du #{note?.dateFr} à #{note?.hour}"}
							]
							new VExercice {
								oNote:note
								links:{ notes:"notes-eleve:#{user.id}/devoir:#{aUF}/note:" }
							}
						}
				}
				{
					regex:/// ^connexions$ ///i
					exec:(m)->
						unless Controller.uLog.cons then Controller.uLog.cons = new CCons()
						Controller.uLog.cons.on { type:"fetch", cb:()->
							Controller.setAriane [
								{text:"Liste des connexions"}
							]
							new VConsList { }
						}
						Controller.uLog.cons.fetch()
				}
			]
			when user.isProf then @routes = [
				{
					regex:/// ^deconnexion$ ///i
					exec:(m)->
						Controller.uLog.deconnexion { cb: ()-> new VHome {} }
						@setAriane()
				}
				{
					regex:/// ^comptes$ ///i
					exec:(m)->
						@setAriane [{text:"Liste de vos élèves"}]
						new VUsersList {}
				}
				{
					regex:/// ^classes$ ///i
					exec:(m)->
						@setAriane [{text:"Liste de vos classes"}]
						new VClassesList {}
				}
				{
					regex:/// ^devoirs$ ///i
					exec:(m)->
						@setAriane [{text:"Liste de vos devoirs"}]
						new VFichesList {}
				}
				{
					regex:/// ^exercices$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des exercices"}]
						new VExercicesList {}
				}
			]
			when user.isEleve then @routes = [
				{
					regex:/// ^deconnexion$ ///i
					exec:(m)->
						Controller.uLog.deconnexion { cb: ()-> new VHome {} }
						@setAriane()
				}
				{ #mon-compte/edit
					regex:/// ^mon-compte/edit$ ///i
					exec:(m)->
						@setAriane [
							{text:"Modification de mon compte"}
						]
						new VUserMod {
							item:Controller.uLog
							container:"#mainContent"
							links: { cancel:"Home" }
						}
				}
				{
					regex:/// ^exercices$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des exercices"}]
						new VExercicesList {}
				}
				{
					regex:/// ^nouvelinscrit$ ///i
					exec:(m)->
						@setAriane []
						new VHome { nouveau:true }
				}
				{
					regex:/// ^mes-exercices$ ///i
					exec:(m)->
						@setAriane [{text:"Mes exercices inachevés"}]
						new VNotesList {
							filtre:{finished:false}
							unfinished:true
							user:Controller.uLog
							links:{ notes:"mes-exercices:" }
						}
				}
				{
					regex:/// ^mes-exercices:([0-9]+)$ ///i
					exec:(m)->
						if (note = Controller.uLog.notes().get Number(m[1]))?
							oEF = note.exoFiche()
							@setAriane [{link:"mes-exercices", text:"Mes exercices inachevés"},{text:"Exercice : #{oEF?.exercice.title} | Essai du #{note.dateFr} à #{note.hour}"}]
							new VExercice {
								oNote:note
								links:{ notes:"mes-exercices:" }
							}
				}
				{
					regex:/// ^devoir:([0-9]+)$ ///i
					exec:(m)->
						Controller.uLog.load { obj:Number(m[1]), cb:(aUF,user)->
							# Normalement chargé avec un utilisateur élève
							oUF = user.UFlist.get aUF, {idUser:user.id}
							if (fiche = oUF?.fiche())?
								if fiche.actif and oUF.actif then Controller.setAriane [{text:"Devoir : #{fiche.nom}"}]
								else Controller.setAriane [{text:"Devoir : #{fiche.nom} [Vérouillé]"}]
								new VList_aEF {
									fiche: fiche
									aUF:aUF
									links: { direct:"devoir:#{aUF}/exercice:", test:null, notes:"notes-devoir:" }
								}
						}
				}
				{
					regex:/// ^devoir:([0-9]+)/exercice:([0-9]+)$ ///i
					exec:(m)->
						Controller.uLog.load { obj:{aUF:Number(m[1]), aEF:Number(m[2])}, cb:(p,user)->
							# Normalement chargé avec un utilisateur élève
							# On transmet les paramètres oUF et uri via l'objet p
							{ aUF, aEF} = p
							oUF = user.UFlist.get aUF, {idUser:user.id}
							fiche = oUF?.fiche()
							if (oEF = fiche?.exercices?.get aEF)?
								if fiche.actif and oUF.actif
									Controller.setAriane [
										{link:"devoir:#{oUF.id}", text:"Devoir : #{fiche.nom}"}
										{text:"Exercice : #{oEF.exercice.title}"}
									]
									new VExercice { oEF:oEF, aUF:aUF }
								else
									Controller.setAriane [
										{link:"devoir:#{aUF}", text:"Devoir : #{oEF.fiche()?.nom} [Vérouillé]"}
										{text:"Notes pour l'exercice : #{oEF.exercice.title}"}
									]
									new VNotesList {
										fiche:fiche
										exoFiche:oEF
										filtre:{aEF:oEF.id, aUF:aUF}
										user:user
										link:"devoir:#{aUF}/exercice:#{oEF.id}"
									}
						}
				}
				{
					regex:/// ^mes-notes$ ///i
					exec:(m)->
						@setAriane [ {text:"Mes notes"} ]
						new VList_aUF {
							filtre:{idUser:Controller.uLog.id}
							showFiche:true
							user:Controller.uLog
							links:{ direct:"mes-notes/devoir:", indirect:null }
						}
				}
				{
					regex:/// ^mes-notes/devoir:([0-9]+)$ ///i
					exec:(m)->
						# uLog déjà chargé
						oUF=Controller.uLog.UFlist.get(Number(m[1]), {idUser:Controller.uLog.id} )
						fiche = oUF?.fiche()
						@setAriane [
							{link:"mes-notes", text:"Mes notes"}
							{text:"Devoir : #{fiche.nom}"}
						]
						new VList_aEF {
							fiche:fiche
							aUF:oUF.id
							links: { direct:"mes-notes/devoir:#{m[1]}/exercice:", test:null, notes:"notes-devoir:" }
						}
				}
				{
					regex:/// ^mes-notes/devoir:([0-9]+)/exercice:([0-9]+)$ ///i
					exec:(m)->
						# uLog déjà chargé
						aUF = Number m[1]
						aEF = Number m[2]
						oUF=Controller.uLog.UFlist.get(aUF, {idUser:Controller.uLog.id} )
						fiche = oUF?.fiche()
						oEF = fiche?.exercices?.get Number aEF
						@setAriane [
							{link:"mes-notes", text:"Mes notes"}
							{link:"mes-notes/devoir:#{aUF}", text:"Devoir : #{fiche?.nom}"}
							{text:"Exercice : #{oEF?.exercice.title}"}
						]
						new VNotesList {
							fiche:fiche
							exoFiche:oEF
							aUF:aUF
							filtre:{aEF:aEF, aUF:aUF}
							user:Controller.uLog
							link:"mes-notes/devoir:#{aUF}/note:"
						}
				}
				{
					regex:/// ^mes-notes/devoir:([0-9]+)/note:([0-9]+)$ ///i
					exec:(m)->
						# uLog déjà chargé
						aUF = Number m[1]
						idNote = Number m[2]
						oUF=Controller.uLog.UFlist.get(aUF, {idUser:Controller.uLog.id} )
						fiche = oUF?.fiche()
						note=Controller.uLog.notes().get idNote
						oEF = note?.exoFiche()
						@setAriane [
							{link:"mes-notes", text:"Mes notes"}
							{link:"mes-notes/devoir:#{aUF}", text:"Devoir : #{fiche?.nom}"}
							{link:"mes-notes/devoir:#{aUF}/exercice:#{oEF?.id}", text:"Exercice : #{oEF?.exercice.title}"}
							{text:"Essai du #{note?.dateFr} à #{note?.hour}"}
						]
						new VExercice {
							oNote:note
							links:{ notes:"mes-notes/devoir:#{aUF}/note:"}
						}
				}
			]
			when user.local then @routes = [
				{ # aussi prof et élève et local
					regex:/// ^exercices$ ///i
					exec:(m)->
						@setAriane [{text:"Liste des exercices"}]
						new VExercicesList {}
				}
				{ # aussi prof et élève et local
					regex:/// ^tester-exercice:([0-9]+)$ ///i
					exec:(m)->
						@setAriane [
							{link:"exercices", text:"Liste des exercices"}
							{text:"Test d'un exerice"}
						]
						new VExercice { idE:Number m[1] }
				}
			]
			else @routes = [
				{
					regex:/// ^connexion$ ///i
					exec:(m)->
						Controller.uLog.on { type:"connexion", cb: ()-> new VHome {} }
						@setAriane()
						new VConnexion { container:"#mainContent" }
				}
				{
					regex:/// ^rejoindre-une-classe:([0-9]+)$ ///i
					exec:(m)->
						if (classe = Controller.uLog.classes.get Number(m[1]))?
							@setAriane [
								{link:"rejoindre-une-classe", text:"Rejoindre une classe"}
								{text:classe.nom}
							]
							new VInscription { classe:classe }
						else new VClassesJoin {}
				}
				{
					regex:/// ^rejoindre-une-classe$ ///i
					exec:(m)->
						@setAriane [{text:"Rejoindre une classe"}]
						new VClassesJoin {}
				}
				{
					regex:/// ^reinit:([a-z0-9]+)$ ///i
					exec:(m)->
						Controller.uLog.on { type:"reinitMDP", cb: (user,success)->
							Controller.setAriane()
							new VHome { reinit:success }
							if success then new VUserMod { item:user, mdp:true }
							else Controller.notyMessage "La clef n'est pas ou plus valide", "error"
						}
						Controller.uLog.reinitMDP m[1]
				}
			]
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
		if (@uLog isnt null) and (not @uLog.isOff) and (uri.toLowerCase() isnt "deconnexion")
			currentTime = (new Date()).getTime()
			delta = currentTime - @lastTime
			if delta>60000
				$.post("./action.php?action=logged", { }, @updateLoggedTime, "json")

		unless routeFound then @defaultView()
	@updateLoggedTime: (data) =>
		if data.logged then @lastTime = (new Date()).getTime()
		else new VConnexion { reconnexion:true }
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

