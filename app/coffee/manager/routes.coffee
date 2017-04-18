# Dans le choix admin/prof il peut y avoir un distingo utilisateurs/élèves

routes = [

	{# deconnexion
		admin:true
		prof:true
		eleve:true
		regex:/// ^deconnexion$ ///i
		exec:(m)->
			Controller.uLog.deconnexion { cb: ()-> new VHome {} }
			@setAriane()
	}
	{# comptes
		regex:/// ^comptes$ ///i
		admin:true
		prof:true
		exec:(m)->
			if @uLog.isAdmin then @setAriane [{text:"Liste des utilisateurs"}]
			else @setAriane [{text:"Liste des élèves"}]
			new VUsersList {}
	}
	{ #utilisateurs/add
		regex:/// ^utilisateurs/add$ ///i
		admin:true
		prof:true
		exec:(m)->
			@setAriane [
				{link:"comptes", text:"Liste des utilisateurs"}
				{text:"Ajout d'un utilisateur"}
			]
			new VUserMod {
				links: { cancel:"comptes" }
			}
	}
	{ #utilisateur:id/edit
		admin:true
		prof:true
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
					links: { cancel:"comptes" }
				}
	}
	{ #mon-compte/edit
		admin:true
		prof:true
		eleve:true
		regex:/// ^mon-compte/edit$ ///i
		exec:(m)->
			@setAriane [
				{text:"Modification de mon compte"}
			]
			new VUserMod {
				item:Controller.uLog
				links: { cancel:"Home" }
			}
	}
	{# classes
		admin:true
		prof:true
		regex:/// ^classes$ ///i
		exec:(m)->
			@setAriane [{text:"Liste des classes"}]
			new VClassesList { links:{ classe:"eleves-de-la-classe:"} }
	}
	{# classes/add
		admin:true
		prof:true
		regex:/// ^classes/add$ ///i
		exec:(m)->
			@setAriane [
				{link:"classes", text:"Liste des classes"}
				{text:"Création d'une classe"}
			]
			new VClasseMod {
				links: { cancel:"classes" }
			}
	}
	{ # classe:id/edit
		admin:true
		prof:true
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
					links: { cancel:"classes" }
				}
	}
	{ # exercices
		admin:true
		prof:true
		eleve:true
		local:true
		regex:/// ^exercices$ ///i
		exec:(m)->
			@setAriane [{text:"Liste des exercices"}]
			new VExercicesList {}
	}
	{ # tester-exercice:id - aussi prof et élève et local
		admin:true
		prof:true
		eleve:true
		local:true
		regex:/// ^tester-exercice:([0-9]+)$ ///i
		exec:(m)->
			@setAriane [
				{link:"exercices", text:"Liste des exercices"}
				{text:"Test d'un exerice"}
			]
			new VExercice { idE:Number m[1] }
	}
	{ # devoirs
		admin:true
		prof:true
		regex:/// ^devoirs$ ///i
		exec:(m)->
			@setAriane [{text:"Liste des devoirs"}]
			new VFichesList { links:{
				devoir:"devoir:"
				notes:"notes-devoir:"
			} }
	}
	{ # devoirs/add
		admin:true
		prof:true
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
				links: { cancel:"devoirs" }
			}
	}

	{ # devoir:id
		admin:true
		prof:true
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
	{ # devoir:id/edit
		admin:true
		prof:true
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
					links: { cancel:"devoirs" }
				}
			}
	}
	{ # devoir:id/add - ajout d'un exercice dans une fiche
		admin:true
		prof:true
		regex:/// ^devoir:([0-9]+)/add$ ///i
		exec:(m)->
			fiche = Controller.uLog.fiches.get(Number m[1])
			fiche?.load { type:"load", cb:(fiche)->
				Controller.setAriane [
					{link:"devoirs", text:"Liste des devoirs"}
					{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
					{text:"Ajout d'un exercice"}
				]
				new VExercicesList {
					fiche:fiche
					links:{ cancel: "devoir:#{fiche.id}" }
				}
			}
	}
	{ # devoir:id/add:id - ajout d'un exercice dans une fiche
		admin:true
		prof:true
		regex:/// ^devoir:([0-9]+)/add:([0-9]+)$ ///i
		exec:(m)->
			fiche = Controller.uLog.fiches.get(Number m[1])
			idExercice = Number m[2]
			fiche?.load { type:"load", cb:(fiche)->
				Controller.setAriane [
					{link:"devoirs", text:"Liste des devoirs"}
					{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
					{text:"Ajout d'un exercice"}
				]
				new VExoFicheMod {
					item:idExercice
					fiche:fiche
					links:{ cancel: "devoir:#{fiche.id}" }
				}
			}
	}
	{ # devoir:id/edit:id - Modification d'un exercice dans une fiche
		admin:true
		prof:true
		regex:/// ^devoir:([0-9]+)/edit:([0-9]+)$ ///i
		exec:(m)->
			fiche = Controller.uLog.fiches.get(Number m[1])
			idEF = Number m[2]
			fiche?.load { type:"load", cb:(fiche)->
				Controller.setAriane [
					{link:"devoirs", text:"Liste des devoirs"}
					{link:"devoir:#{fiche.id}", text:"Devoir : #{fiche.nom}"}
					{text:"Ajout d'un exercice"}
				]
				new VExoFicheMod {
					item:fiche.exercices.get(idEF)
					fiche:fiche
					links:{ cancel: "devoir:#{fiche.id}" }
				}
			}
	}
	{ # devoir:id/exam
		admin:true
		prof:true
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
	{ # exam:id/edit
		admin:true
		prof:true
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
					links: { cancel:"devoir:#{m[1]}/exams" }
				}
			}
	}
	{ # devoir:id/exam:id/exo:id
		admin:true
		prof:true
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
	{ # devoir:id/ajout-exercice - Est-il encore d'actualité ???
		admin:true
		prof:true
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
	{ # devoir:id/tester-exercice:id
		admin:true
		prof:true
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
	{ # notes-devoir:id
		admin:true
		prof:true
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
	{ # notes-devoir:id/ajout-eleve
		admin:true
		prof:true
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
	{ # notes-devoir:id/eleve:id
		# Liste des exercices pour un devoir et un élève (donc pour un aUF)
		# C'est un parcours depuis le devoir
		# Il est utile d'avoir tous les élèves du devoir afin de permettre un parcours entre élèves
		admin:true
		prof:true
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
	{ # note-devoir:id/eleve:id/exercice:id
		# Liste des notes pour un exercice donné dans un aUF
		# C'est un parcours depuis le devoir
		# Il est utile d'avoir tous les élèves du devoir afin de permettre un parcours entre élèves
		admin:true
		prof:true
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
	{ # note-devoir:id/eleve:id/note:id
		# Une note dans un exercice dans un aUF
		# C'est un parcours depuis le devoir
		# Il est utile d'avoir tous les élèves du devoir afin de permettre un parcours entre élèves
		admin:true
		prof:true
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
	{ # eleves-de-la-classe:id
		admin:true
		prof:true
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
	{ # notes-eleve:id
		# Liste des devoirs d'un élève, avec les notes
		admin:true
		prof:true
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
		admin:true
		prof:true
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
	{ # notes-eleve:id/devoir:id/exercice:id
		# Liste des notes pour un exercice donné dans un aUF
		# C'est un parcours depuis l'élève
		# Il est utile d'avoir tous les devoirs de l'élève afin de permettre un parcours entre devoirs
		admin:true
		prof:true
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
	{ # notes-eleve:id/devoir:id/note:id
		# Une note dans un exercice dans un aUF
		# C'est un parcours depuis l'élève
		# Il est utile d'avoir tous les devoirs de l'élève afin de permettre un parcours entre devoirs
		admin:true
		prof:true
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
		admin:true
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
