
Exercice.liste.push
	id:37
	title:"Dérivée d'une fonction trigonométrique"
	description:"Dériver une fonction de la forme $f(t)=A\\sin(\\omega t+\\varphi)$."
	keyWords:["Dérivation","Trigonométrie","Première"]
	init: (data) ->
		inp = data.inputs
		unless inp.f? then inp.f = "#{ mM.alea.real { min:1, max:50 } } #{ mM.alea.in ["cos","sin"] }(#{ mM.alea.real { min:0, max:30, sign:true } } t #{ mM.alea.in ["+","-"] } #{ mM.alea.real { min:0, max:30 } })"
		f = mM.toNumber(inp.f).simplify()
		fDer = f.derivate("t")
		fTex = "f: t \\mapsto #{f.tex()}"
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère la fonction $#{fTex}$. Vous devez donner l'expression de sa dérivée.</p><p><i>Attention : La variable choisie est $t$ et pas $x$ !</i></p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Expression de la dérivée $f'$"
				liste:[{
					tag:"$f'(t)=$"
					name:"u"
					description:"Expression de f'"
					good: fDer
					forme:{fraction:true}
				}]
				aide:oHelp.trigo.derivee
			}
		]
