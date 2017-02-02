
#----------Collection---------

class Collection extends MObject
	constructor: (@type, ops)->
		@_operands = []
		if isArray(ops) then @_operands.push item for item in ops
	push: ->
		for item in arguments
			if (item instanceof Collection) and (item.type is @type) then @_operands.push item._operands...
			else @_operands.push item
		@
	simplify: (infos=null) ->
		@_operands[i] = op.simplify(infos) for op,i in @_operands
		@
	toClone: ->
		out = new Collection(@type)
		out.push(op.toClone()) for op in @_operands
		out
	tex: -> (op.tex() for op in @_operands).join(@type)
	toString: -> (String(op) for op in @_operands).join(@type)
	getOperands: -> @_operands
	toEquation: -> new Equation(@operands[0], @operands[1])
class Equation extends MObject
	constructor: (gauche, droite)->
		@gauche = @affectation gauche
		@droite = @affectation droite
	affectation: (value) ->
		if value instanceof NumberObject then value
		else new RealNumber()
	simplify: (infos=null,developp=false) ->
		@gauche = @gauche.simplify(infos,developp)
		@droite = @droite.simplify(infos,developp)
		@
	reduct: ->
		unless @_reduct? then @_reduct = @gauche.toClone().am(@droite,true).simplify(null,true)
		@_reduct
	toClone: ->
		mg = @gauche.toClone()
		md = @droite.toClone()
		new Equation(mg,md,@isValid)
	tex: (config)-> "#{@gauche.tex(config)} = #{@droite.tex(config)}"
	toString: -> "#{ @gauche } = #{ @droite }"
	isEqual: (other)->
		if not(other instanceof Equation) then return false
		eq1 = @reduct()
		norm1 = @normalize(eq1)
		# S'il n'y a aucun symbole à réduire on considère que ça ne va pas
		if norm1 is null then return false
		eq2 = other.reduct()
		norm2 = @normalize(eq2,norm1.signature)
		if norm2 is null then return false
		eq1.toClone().md(norm2.factor,false).am(eq2.toClone().md(norm1.factor,false),true).developp().simplify(null,false).isNul()
	distance: (other)->
		if @isEqual(other) then 0
		else 1
	normalize: (nObj, signature) ->
		# Cette fonction est utilisée pour comparer deux équations
		# Elle consiste à chercher la présence d'un symbole dans un numberObject développé
		# et de voir son coefficient.
		# En comparant entre deux, on peut trouver s'il y a une combinaison linéaire passant de l'un à l'autre
		# On peut préciser signature si on recherche une signature particulière
		unless typeof signature is "string" then signature = null
		switch
			when nObj instanceof PlusNumber
				for op in nObj.getOperands()
					sign = op.signature()
					if (sign is signature) or (signature is null) and (sign isnt "1") and (sign isnt "N/A") and (op.isFunctionOf().length > 0)
						# Dans ce cas on a trouvé un élément avec une signature et qui contient un symbole
						return { signature: sign, factor:op.toClone().extractFactor() }
			when nObj instanceof NumberObject
				sign = nObj.signature()
				if (sign is signature) or (signature is null) and (sign isnt "1") and (sign isnt "N/A") and (nObj.isFunctionOf().length > 0)
					# Dans ce cas on a trouvé un élément avec une signature et qui contient un symbole
					return { signature: sign, factor:nObj.toClone().extractFactor() }
		null
#----------Ensembles---------
class EnsembleObject extends MObject
	# C'est par défaut un ensemble vide
	@make: (openingDelimiter, operands, closingDelimiter) ->
		out = new Ensemble()
		switch
			when (openingDelimiter is "{") and (closingDelimiter is "}")
				out.push(op) for op in operands
			when ((openingDelimiter is "[") or (openingDelimiter is "]")) and ((closingDelimiter is "[") or (closingDelimiter is "]")) and (operands.length is 2)
				out.init(openingDelimiter is "[",operands[0],closingDelimiter is "]",operands[1])
		out
	isEmpty: -> true
	contains: (value) -> false
	tex: -> "\\varnothing"
	toString: -> "∅"
	toStringCustom: (widthPar=false) -> String(@)
	toClone: -> new EnsembleObject()
	inverse: -> (new Ensemble()).inverse()
	intersection: (operand) -> @
	union: (operand) -> operand.toClone()
	simplify: -> new Ensemble()
class Union extends EnsembleObject
	constructor: ->
		@_operands = []
		for item in arguments
			if item instanceof Union then @_operands.push item._operands...
			else if item instanceof EnsembleObject then @_operands.push item
	isEmpty: ->
		if @_operands.length is 0 then return true
		for op in @_operands
			if not op.isEmpty() then return false
		true
	contains: (value) ->
		for op in @_operands
			if op.contains(value) then return true
		false
	tex: (widthPar = false)->
		if @_operands.length is 0 then return "\\varnothing"
		else
			out = (op.tex() for op in @_operands).join("\\cup")
			if (@_operands.length >1) and widthPar then return "\\left("+out+"\\right)"
			else return out
	toString: ->
		if @_operands.length is 0 then return "∅"
		else return (String(op) for op in @_operands).join("∪")
	toStringCustom: (widthPar=false) ->
		if @_operands.length>1 and widthPar then return "("+String(@)+")"
		else return String(@)
	toClone: -> new Union( (op.toClone() for op in @_operands)... )
	inverse: -> @simplify().inverse()
	intersection: (operand) -> new Intersection(@, operand.toClone())
	union: (operand) ->
		if operand instanceof Union then @_operands.push operand.toClone()._operands...
		else if operand instanceof EnsembleObject then @_operands.push operand.toClone()
		@
	simplify: (infos=null) ->
		if @_operands.length is 0 then return new Ensemble()
		out = @_operands.pop().simplify()
		out = out.union(op.simplify()) while (op = @_operands.pop())
		out
class Intersection extends EnsembleObject
	constructor: ->
		@_operands = []
		for item in arguments
			if item instanceof Intersection then @_operands.push item._operands...
			else @_operands.push item
	isEmpty: ->
		if @_operands.length is 0 then return true
		return @toClone().simplify().isEmpty()
	contains: (value) ->
		for op in @_operands
			if not op.contains(value) then return false
		true
	tex: ->
		if @_operands.length is 0 then return "\\varnothing"
		else return (op.tex(true) for op in @_operands).join("\\cap")
	toString: ->
		if @_operands.length is 0 then return "∅"
		else return (op.toStringCustom(true) for op in @_operands).join("∩")
	toClone: -> new Intersection( (op.toClone() for op in @_operands)... )
	inverse: -> @simplify().inverse()
	intersection: (operand) ->
		if operand instanceof Intersection then @_operands.push operand.toClone()._operands...
		else if operand instanceof EnsembleObject then @_operands.push operand.toClone()
		@
	union: (operand) -> new Union(@, operand.toClone())
	simplify: (infos=null) ->
		if @_operands.length is 0 then return new Ensemble()
		out = @_operands.pop().simplify()
		out.intersection(op.simplify()) while (op=@_operands.pop())
		out
class Ensemble extends EnsembleObject
	# La _liste est triée et chaque élément contient un symbole : true pour '[' ou false pour ']', et une valeur numérique de type NumberObject, réel
	# On n'inserre jamais une borne à +infini car elle ne sert à rien : S'il y a 2n+1 bornes,
	# alors sous-entendu la dernière est +infini[
	constructor: ->
		@_liste = []
	simplify: (infos = null) ->
		op.value = op.value.simplify(infos) for op in @_liste
		@
	setEmpty: ->
		@_liste = []
		@
	isEmpty: -> @_liste.length is 0
	insertBorne: (value, type) ->
		if not (value instanceof NumberObject) or not value.isReal() then return @
		# value est le nombre à insérrer
		# type est true : '[', false : ']'
		type = (type is true) or (type is "[")
		open = false;
		if value instanceof InftyNumber
			if value.isPositive() then return @ # Inserrer +infini ne sert à rien
			else type = false # -infini ne peut être inserré qu'avec ]
		for borne,i in @_liste
			comparaison = borne.value.compare value
			if comparaison is 0
				if type is borne.type
					# la borne inserrée est identique à l'existente => on supprime
					# Ce mécanisme est important pour l'intersection
					@_liste.splice(i,1)
					return @
				else if (type)
					# on considère que [ précède ] donc dans ce cas, la valeur à insérrer
					# précède celle trouvée dans la liste
					@_liste.splice(i,0,{value: value, type: type})
					return @
				# sinon la borne à inserrer est considéré comme plus grande et sera donc insérrée avec la borne d'après
			else if comparaison > 0
				@_liste.splice(i,0,{value: value, type: type})
				return @
			# Autrement on continue à chercher
		@_liste.push({ value: value, type: type })
		@
	contains: (value) ->
		if not (value instanceof NumberObject) or not value.isReal() then return false
		open = false
		for borne in @_liste
			comparaison = borne.value.compare value
			if comparaison is -1 then return open
			if comparaison is 0 then return (open isnt borne.type)
			open = not open
		open
	inverse: -> @insertBorne(new InftyNumber(false), false)
		# Si l'ensemble commence déjà par -Infini, celui sera annulé
		# Sinon il sera ajouté au début
	intersection: (operand) ->
		if not (operand instanceof Ensemble) then return @setEmpty()
		output = new Ensemble()
		if @isEmpty() or operand.isEmpty() then return output
		open1 = open2 = false
		indice2 = 0
		# En cas d'égalité entre un item de la liste1 (@) et de la liste2 (operand)
		# Si dans la liste 1 on a [ on le considère précédent
		# Si dans la liste 1 on a ] on le consdidère suivant
		for borne1 in @_liste
			borne_atteinte = false
			while (indice2<operand._liste.length) and not borne_atteinte
				# On fait défiler les items de liste2 qui précèdent celle de borne1
				borne2 = operand._liste[indice2]
				comparaison = borne2.value.compare borne1.value
				if comparaison >= 0 then borne_atteinte = true
				if (comparaison<0) or ((comparaison is 0) and not borne1.type)
					# borne2.value est intégrée.
					# En cas d'égalité, si (not borne1.type)=>], borne2.value précède
					if open1 then output.insertBorne(borne2.value.toClone(),borne2.type)
					open2 = not open2
					indice2++
			# borne2.value est soit infini (tableau terminé) soit supérieure à borne1.value
			if open2 then output.insertBorne(borne1.value.toClone(),borne1.type)
			open1 = not open1
		if open1
			# La liste de @ est terminée. Il faut être sûr de terminer celle de operand
			while indice2<operand._liste.length
				borne2 = operand._liste[indice2]
				output.insertBorne(borne2.value.toClone(),borne2.type)
				indice2++;
		output
	union: (operand) ->
		if not(operand instanceof Ensemble) then return @
		if operand.isEmpty() then return @
		if @isEmpty() then return operand.toClone()
		# On exploite : A OU B = NON(NON(A) ET NON(B))
		@inverse().intersection(operand.toClone().inverse()).inverse()
	insertSingleton: (value) ->
		if typeof value is "number" then value = new RealNumber(value)
		if not(value instanceof NumberObject) or not value.isReal() then return @
		open = false
		for borne in @_liste
			comparaison = borne.value.compare value
			if comparaison is -1
				if not open then @insertBorne(value.toClone(),true).insertBorne(value.toClone(), false)
				return @
			if comparaison is 0
				if open is borne.type then borne.type = not borne.type
				return @
			open = not open
		if not open then @insertBorne(value.toClone(),true).insertBorne(value.toClone(), false)
		@
	init: (included_ouvrant, valeurOuvrante, included_fermant, valeurFermante) ->
		@setEmpty()
		if valeurOuvrante.compare(valeurFermante)<=0
			@insertBorne(valeurOuvrante, included_ouvrant is true)
			@insertBorne(valeurFermante, included_fermant is false)
		else
			@insertBorne(valeurFermante, included_fermant is true)
			@insertBorne(valeurOuvrante, included_ouvrant is false)
		@
	toString: ->
		if @isEmpty() then return '∅';
		intervalles = []
		borneOpen = null
		for borne in @_liste
			if borneOpen is null
				borneOpen = borne
				if borne.type then str = "[#{borne.value};"
				else str = "]#{borne.value};"
			else
				# Fermeture de l'intervalle (qui peut être un singleton)
				if borne.value.compare(borneOpen.value) is 0
					str = "{#{borne.value}}"
				else
					if borne.type then str += "#{borne.value}["
					else str += "#{borne.value}]"
				intervalles.push(str)
				borneOpen = null
		if borneOpen isnt null
			str += "∞["
			intervalles.push(str)
		intervalles.join("∪")
	tex: ->
		if @isEmpty() then return "\\varnothing"
		intervalles = []
		borneOpen = null
		for borne in @_liste
			if borneOpen is null
				borneOpen = borne
				if borne.type then str = "\\left["+borne.value.tex()+";"
				else str = "\\left]#{borne.value.tex()};"
			else
				# Fermeture de l'intervalle (qui peut être un singleton)
				if borne.type then str += borne.value.tex()+"\\right["
				else str += borne.value.tex()+"\\right]"
				intervalles.push(str)
				borneOpen = null
		if borneOpen isnt null
			str += "+\\infty\\right["
			intervalles.push(str)
		intervalles.join("\\cup")
	toClone: ->
		clone = new Ensemble()
		for borne in @_liste
			clone.insertBorne(borne.value, borne.type)
		clone
	# Debug : gérer les deux cas avec value = infini, et nan
	isEqual: (oper,tolerance) ->
		if typeof tolerance is "undefined" then tolerance = 0
		if not (oper instanceof EnsembleObject) then return false
		if not (oper instanceof Ensemble) then oper = oper.toClone().simplify()
		if @_liste.length isnt oper._liste.length then return false
		for item, i in @_liste
			if (tolerance is 0) and (item.value.compare(oper._liste[i].value) isnt 0) or ( item.value.distance(oper._liste[i].value) > tolerance ) then return false
			if item.type isnt oper._liste[i].type then return false
		return true


