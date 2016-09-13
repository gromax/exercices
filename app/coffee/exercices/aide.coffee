oHelp = {
	trinome: {
		discriminant: [
			"Une expression de la forme $P(x)=a\\cdot x^2+b\\cdot x+c$, avec $a,b,c$ trois nombres et $a\\neq 0$, est dite du <b>second degré</b> en $x$."
			"L'équation $P(x)=0$ est une équation du second degré. Ses solutions sont appelées les <b>racines</b> de $P(x)$."
			"Pour déterminer les racines de $P(x)$, on calcule le discriminant : $\\Delta = b^2-4ac$."
		]
		racines: [
			"$\\Delta$ est le discriminant de l'expression du second degré $ax^2+bx+c$ et on appelle racines les solutions de $ax^2+bx+c=0$."
			"Dans le cas $\\Delta < 0$, il n'y a <b>aucune racine réelle</b>. Mais on peut trouver <b>deux racines complexes</b> : $z_1=\\frac{-b-i\\sqrt{-\\Delta}}{2a}$ et $z_2=\\frac{-b+i\\sqrt{-\\Delta}}{2a}$."
			"Dans le cas $\\Delta = 0$, il y a <b>une racine réelle</b> : $x_0=-\\frac{b}{2a}$."
			"Dans le cas $\\Delta > 0$, il y a <b>deux racines réelles</b> : $x_1=\\frac{-b-\\sqrt{\\Delta}}{2a}$ et $x_2=\\frac{-b+\\sqrt{\\Delta}}{2a}$."
		]
		somme_produit: [ "Quand $x+y=S$ et $x\\cdot y=P$, alors $x$ et $y$ sont les solutions de $x^2-Sx+P=0$." ]
		a_et_concavite_parabole: [ "Le signe de $a$ donne la concavité : Pour $a>0$, la courbe est convexe, c'est à dire ne forme de $\\cup$ ; pour $a < 0$, la courbe est concave, c'est à dire en forme de $\\cap$." ]
		canonique_et_parabole: [ "Certaines fonctions sont données sous leur forme canonique : $f(x)=a\\left(x-x_S\\right)^2+y_S$. Dans ce cas, $x_S$ et $y_S$ donnent directement les coordonnées du sommet de la parabole." ]
		c_et_parabole: [ "Quand l'expression est sous la forme $f(x)=ax^2+bx+c$, le $c$ donne directement $f(0)$, l'ordonnée à l'origine, c'est à dire l'ordonnée pour laquelle la courbe coupe l'axe vertical." ]
		delta_et_parabole: [ "Le signe de $\\Delta$ donne le nombre d'intersection avec l'axe horizontal : Si $\\Delta < 0$, la courbe ne touche jamais l'axe horizontal ; si $\\Delta = 0$, la courbe touche l'axe en son sommet ; si $\\Delta > 0$ alors la courbe coupe deux fois l'axe." ]
	}
	geometrie : {
		analytique : {
			milieu : [ "Le milieu de $[AB]$ a pour coordonnées $x_M=\\frac{x_A+x_B}{2}$ et $y_M=\\frac{y_A+y_B}{2}$. Cette formule reste valable dans tous les repères, même non orthogonaux." ]
			symetrique : [ "Le Point $B$ est milieu de $[AA']$, on a donc $x_B=\\frac{x_A+x_{A'}}{2}$ et $y_B=\\frac{y_A+y_{A'}}{2}$." ]
			plg : [
				"Pour que $ABCD$ soit un parallélogramme, il faut que $[AC]$ et $[BD]$ aient le même milieu. On peut donc passer par les coordonnées des milieux."
				"Suivant la même idée, on peut aussi dire que $D$ est le symétrique e $B$ par rapport au milieu de $[AC]$. Il faut alors calculer les coordonnées du milieu de $[AC]$ puis faire le calcul de la symétrie."
				"La technique la plus efficace reste d'utiliser les vecteurs : on doit avoir $\\overrightarrow{AB} = \\overrightarrow{DC}$. On calcule les coordonnées des deux vecteurs ce qui donne les équations pour trouver $x_D$ et $y_D$."
			]
			distance : [
				"La formule est alors : $AB = \\sqrt{\\left(x_A-x_B\\right)^2+\\left(y_A-y_B\\right)^2}$."
				"Dans certains cas, il est plus avantageux d'écrire : $AB^2 = \\left(x_A-x_B\\right)^2+\\left(y_A-y_B\\right)^2$."
			]
		}
	}
	interface : {
		sqrt : [ "Utilisez <b>sqrt()</b> pour racine carrée.</i> exemple : sqrt(43) pour $\\sqrt{43}$ ou 4 sqrt(5) pour $4\\sqrt{5}$. <i>sqrt signifie square root.</i>" ]
	}
	stats : {
		N : [ "L'effectif total est la somme des effectifs : $N=n_1+n_2+\\cdots$." ]
		moyenne : [ "La moyenne a pour formule $\\overline{x} = \\frac{n_1x_1+n_2x_2+\\cdots}{N}$." ]
		ecart_type : [
			"L'écart-type a pour formule : $\\sigma = \\sqrt{\\frac{n_1x_1^2+n_2x_2^2+\\cdots}{N}-\\overline{x}^2}$."
			"La formule de l'écart-type est complexe. Il vaut mieux utiliser les fonctions spéciales de la calculatrice ou d'un tableur pour l'obtenir."
		]
		mediane : [
			"La médiane est la valeur qui coupe la série en deux moitiés de même effectif. Quand $N$ est impair, cette valeur est dans la série. Quand $N$ est pair, il faut prendre la médiane à mi-chemin entre les deux valeurs au centre de la série. Dans de nombreux cas, il suffit de prendre la valeur pour laquelle la FCC dépasse 50%."
			"La médiane donnée par la calculatrice est toujours bonne, contrairement aux quartiles."
		]
		quartiles : [
			"Le premier quartile $Q_1$ est la valeur pour laquelle la <b>fréquence cumulée croissante</b> atteint ou dépsse 25%."
			"Le troisième quartile $Q_3$ est la valeur pour laquelle la <b>fréquence cumulée croissante</b> atteint ou dépsse 75%."
			"<b>Attention :</b> $Q_1$ et $Q_3$ sont toujours des valeurs de la série. La calculatrice utilise une autre définition et peut parfois donner une valeur qui n'est pas dans la série (quand une FCC tombe juste sur 25% ou sur 75%). Dans ce cas, il faut prendre la valeur de la série juste inférieure à la valeur donnée par la calculatrice."
		]
		ajustement: [
			"Ces formules sont données à titre informatif. <b>Faites le calcul directement avec la calculatrice !</b>"
			"L'ajustement affine de $y$ en $x$ nous donne une équation de la forme $y=ax+b$."
			"La méthode des moindres carrés consiste à chercher la droite qui minimise le total des erreurs au carré selon l'axe $y$."
			"La droite des mondres carrés passe par le point moyen : $G\\left(\\overline{x};\\overline{y}\\right)$, donc $b = \\overline{y}-a\\overline{x}$"
			"On obtient également $a = \\frac{C_{xy}}{V(x)}$ "

		]
		covariance: [ "La <b>covariance</b> a pour formule $C_{xy} = \\left( \\frac{1}{N}\\sum_i x_iy_i\\right) - \\overline{x}\\cdot\\overline{y}$ où $N$ est l'effectif total"]
		variance: [ "La <b>variance</b> a pour formule $V(x) = \\left( \\frac{1}{N}\\sum_i x_i^2\\right) - \\left(\\overline{x}\\right)^2$ où $N$ est l'effectif total"]
	}
	proba : {
		binomiale : {
			calculette : [
				"Avec la <b>TI</b>, on peut calculer ces probabilités via les touches <span class=label label-info'>2nde</span><span class='label label-default'>var</span>. La fonction <b>BinomialFdP</b> permet de calculer $p(X=k)$ et la fonction <b>BinomialFRep</b> permet de calculer $p(X\\leqslant k)$."
				"Avec la <b>Casio</b>, on peut calculer ces probabilités via le menu <b>Stats</b> : Choisir <b>DIST</b> avec <span class='label label-default'>F5</span> puis <b>BINM</b> avec <span class='label label-default'>F5</span>. Ensuite, si on veut calculer $p(X=k)$, il faut choisir <b>Bpd</b> avec <span class='label label-default'>F1</span> ; si on veut calculer $p(X\\leqslant k)$, il faut choisir <b>Bcd</b> avec <span class='label label-default'>F2</span>."
			]
			esperance : [
				"L'<b>espérance</b> est la valeur attendue. <b>Exemple : </b>Dans un élevage de chiens on a une fréquence $p$ de chiens noirs. On en prélève $n$ au hasard. On s'attend à obtenir $E(X)=n\\times p$ chiens noirs."
			]
			ecart_type : [
				"L'<b>écart type</b> $\\sigma$ permet de mesurer un écart avec la valeur attendue. <b>Exemple :</b> Dans une production d'apparails électroniques, une proportion $p$ est défectueuse. On en prélève $n$ au hasard, on s'attend à en obtenir $E(X)=n\\times  de défectueux. Mais le nombre d'appareils vraiment dégectueux peut être un peu différent. Pour savoir si un échantillon est <b>anormalement</b> éloigné de ce qu'on attendait, on utilise $\\sigma$. Jusqu'à $2\\sigma$, c'est un écart raisonnable. Au delà, c'est beaucoup."
			]
			IF_1 : [
				"Attention, les valeurs de $X$ sont des effectifs, donc $a$ et $b$ aussi : Ce sont des nombres de tuyaux. On pourrait dire que $I_F=[a;b]$ mais on préfère donner l'intervalle de fluctuation en fréquences, c'est à dire qu'il faut diviser par l'effectif total : $I_F=\\left[\\frac{a}{n};\\frac{b}{n}\\right]$."
				"Le calcul de seconde ne fonctionne pas car ici, $p$ est trop petit."
				"Avec la <b>TI</b>, on peut calculer les probabilités du tableau via les touches <span class='label label-info'>2nde</span><span class='label label-default'>var</span>. Il faut utiliser la fonction <b>BinomialFRep</b> qui permet de calculer $p(X\\leqslant k)$."
				"Avec la <b>Casio</b>, on peut calculer les probabilités du tableau via le menu <b>Stats</b> : Choisir <b>DIST</b> avec <span class='label label-default'>F5</span> puis <b>BINM</b> avec <span class='label label-default'>F5</span>. Il faut utiliser <b>Bcd</b> avec <span class='label label-default'>F2</span> qui permet de calculer $p(X\\leqslant k)$."
			]
		}
	}
	trigo: {
		radian : [
			"La mesure d'un angle correspond au placement d'un point sur le cercle trigonométrique. Quand cet angle est en radians, la mesure représente la longueur du parcours entre le point de départ (généralement $I$) et le point à placer, le long du cercle."
		]
		mesure_principale : [
			"Sur le cercle, on peut aboutir au même point de plusieurs façon (en faisant trois fois le tour du cercle par exemple). La mesure principale correspond au chemin le plus court."
			"Il s'en suit que la mesure principale est toujours entre $\\pi$ (compris) et $-\\pi$ (non compris, par convention)"
		]
		pi : [ "Vous pouvez écrire <b>pi</b> pour $\\pi$." ]
		rad_deg : [ "La conversion de radians a degrés, ou réciproquement, est une simple règle de proportionnalité. Il suffit de se rappeler que $360$ degrés correspondent à $2\\pi$ radians." ]
		derivee : [
			"La dérivée de $t\\mapsto A \\cos(\\omega t+\\varphi)$ est $t\\mapsto -A\\omega \\sin(\\omega t+\\varphi)$."
			"La dérivée de $t\\mapsto A \\sin(\\omega t+\\varphi)$ est $t\\mapsto A\\omega \\cos(\\omega t+\\varphi)$."
		]
	}
	complexes: {
		basics : [
			"Vous devez traiter $i$ comme un symbole ordinaire, comme $x$ par exemple.
						Il faut tenir compte du fait que $i^2=-1$."
			"Pour calculer $\\frac{1}{z}$ on multiplie au numérateur et au dénominateur par le conjugué $\\overline{z}$."
		]
		aire_plg : [ "L'aire du parallélogramme $ABCD$ est $\\mathcal{A} = AB\\times AD \\times \\sin \\widehat{BAC}$. On l'obtient directement en calculant $\\left|Im\\left(z_1\\times\\overline{z_2}\\right)\\right|$." ]
		affixeVecteur : [ "Avec $A$ d'affixe $z_A$ et $B$ d'affixe $z_B$, l'affixe du vecteur $\\overrightarrow{AB}$ est $z_{\\overrightarrow{AB}} = z_B-z_A$." ]
		module : [ "Soit $z=x+iy$. Le module de $z$ est $|z|=\\sqrt{x^2+y^2}$." ]
		argument : [ "Soit $z=x+iy$. Pour trouver $\\theta = Arg(z)$, on utilise $\\cos\\theta = \\frac{Re(z)}{|z|}$ ce qui revient à : $\\theta = \\pm \\arccos\\left(\\frac{Re(z)}{|z|}\\right)$. Le signe de $\\theta$ est donné le même que celui de $Im(z)$." ]
		trigo_alg : [ "Soit un nombre complexe $z$ dont on connaît le module $|z|$ et l'argument $\\theta$. Alors $z = |z|(\\cos\\theta+i\\sin\\theta)$." ]
	}
	vecteur: {
		coordonnees : [ "Le vecteur $\\overrightarrow{AB}$ a pour coordonnées $x=x_B-x_A$ et $y=y_B-y_A$. On note : $\\overrightarrow{AB}\\begin{pmatrix} x_B-x_A \\\\ y_B-y_A \\end{pmatrix}$" ]
	}
	fonction : {
		affine : {
			courbe : [
				"Dans $f(x)=ax+b$, $a$ représente le coefficient directeur de la droite. Plus $a$ est loin de $0$, plus la droite est proche de la verticale. Quand $a>0$, la fonction est croissante, donc la droite est \"montante\"."
				"$b$ représente l'ordonnée à l'origine, c'est à dire l'ordonnée pour laquelle la droite coupe l'axe vertical."
			]
			expression : [
				"Dans l'écriture $f(x)=y$, $x$ est l'antécédent et $y$ l'image. Par exemple, si $f(2)=4$, il faut comprendre que $x=2$ et $y=4$."
				"On sait que $a = \\frac{y_A-y_B}{x_A-x_B}$."
				"Après avoir calculé $a$ on peut calculer $b=y_A-a\\cdot x_A$"
			]
		}
		image_antecedent : [ "Dans l'écriture $f:x\\mapsto y$, $x$ est l'antécédent et $y$ est l'image. On peut écrire aussi $f(x)=y$." ]
	}
	droite : {
		equation_reduite : {
			type : [
				"Quand $x_A = x_B$, l'équation réduite est de la forme $x=a$."
				"Quand $x_A \\neq x_B$, l'équation réduite est de la forme $y=mx+p$."
			]
			verticale : [ "Dans ce cas, l'équation est $x = x_A$." ]
			oblique : [
				"On calcule d'abord $m=\\frac{y_A-y_B}{x_A-x_B}$."
				"On calcule ensuite $p=y_A-mx_A$."
			]
		}
		associer_equation : [
			"Pour trier les droites, il existe plusieurs indices :"
			"Une équation de la forme $x=a$ correspond à une droite verticale."
			"Une équation de la forme $y=a$ correspond à une droite horizontale."
			"Dans une équation de la forme $y=mx+p$, $m$ est le coefficient directeur. Plus $m$ s'éloigne de $0$ plus la droite est proche de la verticale. Quand $m>0$, le droite est \"montante\"."
			"$p$ est l'ordonnée à l'origine, c'est à dire l'ordonnée pour laquelle la droite coupe l'axe vertical."
		]
	}
	derivee : {
		basics : [
			"La dérivée de $x^n$, avec $n\\in\\mathbb{N}$ est $n\\cdot x^{n-1}$."
			"Par exemple, la dérivée de $x^2$ est $2x$ et par suite, la dérivée de $7x^2$ est $7\\cdot 2x = 14x$."
			"Enfin il suffit d'ajouter. Par exemple, la dérivée de $7x^2+15x$ est $7\\cdot 2x + 15 = 14x+15$."
		]
		tangente : [
			"La tangente a toujours une équation réduite de la forme $y=mx+p$."
			"$m$ est le coefficient directeur et est donné par la dérivée : Si on veut la tangente en $x=a$, alors $m=f'(a)$."
			"Une fois $m$ connu, on peut déduire $p$ en tenant compte du fait que la tangente doit passer par le point de la courbe dont l'abscisse vous est donnée. Soit $A\\left(x_A;y_A\\right)$ ce point avec $x_A=a$. On sait alors que $y_A = f(a)$ et que $y_A = m x_A + p$."
			"Pour les amateurs de formule, l'équation de la tangente en $x=a$ est obtenue directement : $\\mathcal{T} : y= f'(a) (x-a)+ f(a)$."
		]
		variation : [
			"Quand une fonction est croissante, sa dérivée est positive"
			"Quand la fonction est décroissante, sa dérivée est négative."
			"Quand la dérivée s'annule en changeant de signe, la fonction atteint un maximum ou un minimum."
		]
	}
	primitive : {
		variation : [
			"Quand une fonction est positive, ses primitives sont croissantes"
			"Quand la fonction est négative, ses primitives sont décroissantes."
			"Quand la fonction s'annule en changeant de signe, ses primitives atteignent un maximum ou un minimum."
		]
	}

}
