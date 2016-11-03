
class @Proba
	@alea: (input) ->
		# produit un nombre aléatoire dont la valeur dépend du type de paramètre
		unless input? then return 1
		switch
			when input is null then 1
			when typeof input is "number" then input
			when (mn=input.min)? and (mx=input.max)?
				sign = if input.sign and (Math.random()<0.5) then -1 else 1
				if isArray(input.no) and (input.no.length>0) # C'est un tableau de valeurs interdites
					out = input.no[0]
					j = 0 # compteur pour éviter un bug (si les conditions sont impossibles à remplir)
					while (out in input.no) and (j<10)
						if input.real isnt true then out = sign* Math.floor((Math.random() * (mx+1-mn)) + mn)
						else out = sign*( (Math.random() * (mx-mn)) + mn )
						j++
				else
					if input.real isnt true then out = sign* Math.floor((Math.random() * (mx+1-mn)) + mn)
					else out = sign*( (Math.random() * (mx-mn)) + mn )
				if input.coeff? then out *= @alea(input.coeff)
				out
			when isArray(input) then input[ Math.floor((Math.random() * input.length) ) ]
			else 1
	@aleaEntreBornes: (a,b,sign=false) ->
		if sign then Math.floor((Math.random() * (b+1-a)) + a)*(Math.floor(Math.random()*2)-.5)*2
		else Math.floor((Math.random() * (b+1-a)) + a)
	@aleaIn: (liste) -> liste[ Math.floor((Math.random() * liste.length) ) ]
	@aleaSign: -> (Math.floor(Math.random()*2)-.5)*2
	@phi: (z,up=false) ->
		# Renvoie la fonction Phi(z), loi normale centrée
		# si up = true, c'est 1-Phi(z)
		LOWER_TAIL_IS_ONE = 8.5		# I.e., Phi(8.5) = .999999999999+
		UPPER_TAIL_IS_ZERO = 16.0	# Changes to power series expression
		FORMULA_BREAK = 1.28		# Changes cont. fraction coefficients
		EXP_MIN_ARG = -708			# I.e., exp(-708) is essentially true 0
		if z < 0
			up = not up
			z = -z
		if (z <= LOWER_TAIL_IS_ONE) or (up && z <= UPPER_TAIL_IS_ZERO)
			y = 0.5 * z * z
			if z > FORMULA_BREAK
				if (-y > EXP_MIN_ARG)
					output = .398942280385 * Math.exp(-y) / (z - 3.8052e-8 + 1.00000615302 / (z + 3.98064794e-4 + 1.98615381364 / (z - 0.151679116635 + 5.29330324926 / (z + 4.8385912808 - 15.1508972451 / (z + 0.742380924027 + 30.789933034 / (z + 3.99019417011))))))
				else output = 0
			else
				output = 0.5 - z * (0.398942280444 - 0.399903438504 * y / (y + 5.75885480458 - 29.8213557808 / (y + 2.62433121679 + 48.6959930692 / (y + 5.92885724438))))
		else
			if up
				# Uses asymptotic expansion for exp(-z*z/2)/alnorm(z)
				# Agrees with continued fraction to 11 s.f. when z >= 15
				# and coefficients through 706 are used.
				y = -0.5*z*z
				if y > EXP_MIN_ARG
					w = -0.5/y  # 1/z^2
					output = 0.3989422804014327*Math.exp(y)/ (z*(1 + w*(1 + w*(-2 + w*(10 + w*(-74 + w*706))))))
					# Next coefficients would be -8162, 110410
				else output = 0
			else output = 0.0
		if up then return output
		else return 1-output
	@erfc: (x) ->
		z = Math.abs(x)
		t = 1.0 / (0.5 * z + 1.0)
		a1 = t * 0.17087277 + -0.82215223
		a2 = t * a1 + 1.48851587
		a3 = t * a2 + -1.13520398
		a4 = t * a3 + 0.27886807
		a5 = t * a4 + -0.18628806
		a6 = t * a5 + 0.09678418
		a7 = t * a6 + 0.37409196
		a8 = t * a7 + 1.00002368
		a9 = t * a8
		a10 = -z * z - 1.26551223 + a9
		a = t * Math.exp(a10)
		if x < 0.0 then a = 2.0 - a
		a
	@erf: (x) -> 1.0 - Proba.erfc(x)
	@erfinv: (y) ->
		a = ((8*(Math.PI - 3)) / ((3*Math.PI)*(4 - Math.PI)))
		if y is 1 then return Number.POSITIVE_INFINITY
		if y is -1 then return Number.NEGATIVE_INFINITY
		if Math.abs(y)>1 then return NaN
		if y<0 then sign = -1.0
		else sign = 1.0
		oneMinusXsquared = 1.0 - ( y * y)
		LNof1minusXsqrd = Math.log( oneMinusXsquared )
		PI_times_a = Math.PI * a
		firstTerm  = Math.pow(((2.0 / PI_times_a) + (LNof1minusXsqrd / 2.0)), 2)
		secondTerm = (LNof1minusXsqrd / a)
		thirdTerm  = ((2 / PI_times_a) + (LNof1minusXsqrd / 2.0))
		primaryComp = Math.sqrt( Math.sqrt( firstTerm - secondTerm ) - thirdTerm )
		scaled_R = sign * primaryComp
		scaled_R
	@phiinv: (y) -> Proba.erfinv(2*y-1)*Math.sqrt(2)
	@gaussianAlea: (moy, std, params) ->
		config = mergeObj {min:Number.NEGATIVE_INFINITY, max:Number.POSITIVE_INFINITY, delta:0},params
		rd = Math.random()
		if rd is 0 then return config.min
		out = Proba.phiinv(rd)*std+moy
		if out<config.min then return config.min
		if out>config.max then return config.max
		if config.delta isnt 0 then out = Math.round(out/config.delta)*config.delta
		out
	@binomial_density: (n,p,k) ->
		if (k>n) or (k<0) or (n<0) or (p<0) or (p>1) then return NaN
		q = 1-p
		# Quelques cas triviaux
		if k is 0 then return Math.pow(q,n)
		if k is 1 then return n*Math.pow(q,n-1)*p
		if k is n-1 then return n*Math.pow(p,n-1)*q
		if k is n then return Math.pow(p,n)
		# Autres cas
		i_success = k
		i_fails = n-k
		more = Math.max i_success, i_fails
		less = Math.min i_success, i_fails
		numerator = [more+1..n]
		denominator = [2..less]
		result = 1
		# On évite qu'un calcul intermédiaire produise un résultat trop grand
		while (numerator.length>0)
			switch
				when result<=1 then result *= numerator.pop()
				when denominator.length>0 then result /= denominator.shift()
				when i_success>0
					i_success--
					result *= p
				when i_fails>0
					i_fails--
					result *= q
		# On termine le calul
		while i_success>0
			i_success--
			result *= p
		while i_fails>0
			i_fails--
			result *= q
		result /= denominator.shift() while denominator.length>0
		result
	@binomial_rep: (n,p,k) ->
		if (k>n) or (k<0) or (n<0) or (p<0) or (p>1) then return NaN
		q = 1-p
		# Quelques cas triviaux
		if k is 0 then return Math.pow(q,n)
		if k is 1 then return Math.pow(q,n-1)*(q+n*p)
		if k is n-1 then return 1-Math.pow(p,n)
		if k is n then return 1
		# Cas général
		u = 1
		v = 1
		r = n-k
		while k>0
			v *=q
			u = (n-k+1)/k*p*u+v
			k--
			while (u>1) and (r>0)
				r--
				v*=q
				u*=q
		while r>0
			r--
			u *= q
		u
	@binomial_IF: (n,p) ->
		esperance = n*p
		std = Math.sqrt(n*p*(1-p))
		low = Math.max Math.round(esperance-2*std), 0
		high = Math.min Math.round(esperance+2*std), n
		# recherche de la transition au-dessus de 2,5%
		pk = @binomial_rep(n,p,low)
		if pk is 0.025 then low++
		else
			k = low
			asc = (pk<.025)
			while (k>0) and (k<esperance) and (pk isnt 0.025) and ((pk<0.025) is asc)
				if asc then k++
				else k--
				pk = @binomial_rep(n,p,k)
			if pk<=0.025 then low = k+1
			else low = k
		# recherche de la transition au-dessus de 97,5%
		pk = @binomial_rep(n,p,high)
		if pk isnt 0.975
			k = high
			asc = (pk<.975)
			while (k<n) and (k>esperance) and (pk isnt 0.975) and ((pk<0.975) is asc)
				if asc then k++
				else k--
				pk = @binomial_rep(n,p,k)
			if pk<0.975 then high = k+1
			else high = k
		return { Xlow:low, Xhigh:high }
