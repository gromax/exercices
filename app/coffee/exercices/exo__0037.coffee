
Exercice.liste.push
	id:37
	title:"Dérivée d'une fonction trigonométrique"
	description:"Dériver une fonction de la forme $f(t)=A\\sin(\\omega t+\\varphi)$."
	keyWords:["Dérivation","Trigonométrie","Première"]
	init: (data) ->
		inp = data.inputs
		unless inp.f? then inp.f = "#{Proba.aleaEntreBornes(1,50)} #{Proba.aleaIn ["cos","sin"]}(#{Proba.aleaEntreBornes(1,20)*Proba.aleaSign()} t #{Proba.aleaIn ["+","-"]} #{Proba.aleaEntreBornes(0,30)})"
		f = NumberManager.makeNumber(inp.f).simplify()
		fDer = f.derivate("t")
		fTex = "f: t \\mapsto #{f.tex()}"
		[
			new BEnonce {zones:[{body:"enonce", html:"<p>On considère la fonction $#{fTex}$. Vous devez donner l'expression de sa dérivée.</p><p><i>Attention : La variable choisie est $t$ et pas $x$ !</i></p>"}]}
			new BListe {
				data:data
				bareme:100
				title:"Expression de la dérivée $f'$"
				liste:[{tag:"$f'(t)=$", name:"u", description:"Expression de f'", good: fDer , params:{ forme:{fraction:true}}}]
				aide:oHelp.trigo.derivee
			}
		]
