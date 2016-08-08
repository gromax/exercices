
Exercice.liste.push
	id:7
	title:"Image et antécédent avec un tableau de valeurs"
	description:"Un tableau de valeur d'une fonction est donné. Il faut déterminer une image et un antécédent."
	keyWords:["Fonctions","Antécédent","Image","Seconde"]
	init: (data) ->
		borne_inf = -7
		borne_sup = 7
		inp = data.inputs
		h_init("a",inp,0,1)
		h_init("b",inp,-5,5)
		h_init("c",inp,1,9)
		h_init("d",inp,-20,20)
		h_init("xi",inp,borne_inf,borne_sup) # x dont on demandera l'image
		yi = @evalPoly(inp,inp.xi)
		h_init("xa",inp,borne_inf,borne_sup) # x dont on calculera l'image afin de demander un antécédent
		ya = @evalPoly(inp,inp.xa)
		# Calcul des valeurs du tableau de variation
		tabx = [borne_inf..borne_sup]
		taby = []
		antecedents = []
		for x in tabx
			taby.push(y = @evalPoly(inp,x))
			if y is ya then antecedents.push x
		[
			new BEnonce {
				zones:[
					{ body:"enonce", html:"<p>On considère la fonction $f$ défnie sur l'intervalle $[#{borne_inf};#{borne_sup}]$, et on donne le tableau de valeur suivant : </p>" }
					{table:"tableau", lignes:[ {entete:"$x$", items:tabx}, {entete:"$y$", items:taby}] }
				]
			}
			new BListe {
				data:data
				bareme:100
				title:"Donnez l'image de #{inp.xi} et un antécédent de #{ya}"
				liste:[
					{tag:"Image de $#{inp.xi}$", name:"i", description:"Valeur décimale", good:yi},
					{tag:"Antécédent de $#{ya}$", name:"a", description:"Valeur décimale", good:antecedents}
				]
				aide: oHelp.fonction.image_antecedent
			}
		]
	evalPoly: (inp,x) -> ((((inp.a*x)+inp.b)*x)+inp.c)*x+inp.d
