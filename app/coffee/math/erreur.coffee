
# objet de gestion d'analyse d'une réponse utilisateur
erreurManager = {
	main: (good, answer,symbols) ->
		# good est un NumberObject
		# answer est un NumberObject
		moduloError=false
		if modulo = good.getModulo()
			floatModulo = Math.abs modulo.floatify(symbols).float()
			answerModuloObject = answer.modulo()
			if (answerModuloObject.modulo isnt false)
				moduloError = (Math.abs(answerModuloObject.modulo.floatify(symbols).float())-floatModulo > ERROR_MIN)
				answer = answerModuloObject.base
			else moduloError = true
			if moduloError then moduloError = modulo.tex()
		else floatModulo = 0
		ecart = good.toClone().am(answer,true).simplify().floatify(symbols).abs().float()
		if floatModulo>0
			ecart -= floatModulo while floatModulo<=ecart
		if ecart<ERROR_MIN then ecart = 0
		if answer instanceof RealNumber
			# Dans ce cas, l'utilisateur donne une valeur numérique
			# Cette valeur peut donc être exacte, ou approximative
			# On cherche l'ordre de grandeur de la justesse de la réponse.
			# On souhaite aussi savoir s'il s'agit d'une troncature au lieu d'une approx
			# On souhaite aussi connaître le nombre de décimales de la réponse de l'utilisateur (p_user)
			if ecart is 0 then return { exact:true, float:true, moduloError:moduloError, p_user:answer.precision() }
			else
				#ordre_exp = Math.ceil(Math.log(ecart)/Math.LN10)
				if (answer.precision()>=2*ecart)
					# L'erreur est plus petite que le degré de précision donné par l'utilisateur
					# C'est ici qu'éventuellement on parlera de troncature
					return { exact:false, float:true, approx_ok:true, ecart:ecart, moduloError:moduloError, p_user:answer.precision() }
				else return { exact:false, float:true, approx_ok:false, ecart:ecart, moduloError:moduloError, p_user:answer.precision() }
		# L'utilisateur donne une formule. On attend donc une valeur exacte.
		{ exact: (ecart is 0), float:false, moduloError:moduloError }
	tri: (usersObj,goodsObj) ->
		# On donne un tableau de réponses utilisateur et un tableau de bonnes réponses
		# On cherche à les associer 2 à 2 et à renvoyer le tableau des bonnes réponses
		# trier dans le bon ordre relativement à users
		# On organise les goods et on en profite pour détecter un modulo
		paired_users = []
		maxIter = usersObj.length*(usersObj.length+1)/2
		# Évite une éventuelle boucle infinie. Dans tous les cas, le nombre d'iter
		# ne devrait pas dépasser n(n+1)/2
		while (usersObj.length>0) and (goodsObj.length>0) and (maxIter>0)
			maxIter--
			closestGood = @searchClosest(usersObj[0],goodsObj)
			closestUser = @searchClosest(closestGood,usersObj)
			if closestUser.rank is usersObj[0].rank
				# On a trouvé une paire
				usersObj[0].closest = closestGood.value # On attache l'objet good à l'objet user
				paired_users.push(usersObj.shift()) # L'objet user est oté de la liste de recherche et poussé dans celles apairés
				goodsObj.splice(closestGood.rank,1) # On retire l'objet good de la liste de recherche
			else
				# La paire n'est pas bonne
				# On remet user à la suite
				usersObj.push(usersObj.shift())
		# Il pourrait rester des users en souffrance
		# Soit faute de good, soit faute d'un dysfonctionnement
		paired_users.push usersObj.pop() while usersObj.length>0
		paired_users.sort (a,b) ->
			if a.rank<b.rank then -1
			else 1
		output = { closests: ( { user:us.value, good:us.closest } for us in paired_users ), lefts:(goodO.value for goodO in goodsObj)}
	searchClosest: (oValue, tab) ->
		# Dans une liste de réponses { value:NumberObject, rank:i }
		# on recherche la plus proche de oValue { value:NumberObject, d:[ float array ] }
		# out pointe sur l'objet le plus proche trouvé à un point du programme
		if tab.length is 0 then return null
		out = tab[0]
		indice = 0
		for oTab,i in tab
			if typeof oValue.d[oTab.rank] is "undefined" then oValue.d[oTab.rank] = oValue.value.distance oTab.value
			if (oValue.d[oTab.rank]<oValue.d[out.rank]) or isNaN(oValue.d[out.rank]) and not isNaN(oValue.d[oTab.rank])
				out = oTab
				indice = i
		out
}
