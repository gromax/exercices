
Exercice.liste.push
	id:31
	title: "Conversion entre degré et radians"
	description: "Transformer une mesure en degrés en une mesure en radians et réciproquement."
	keyWords:["Géométrie", "Trigonométrie", "Seconde"]
	init: (data) ->
		inp = data.inputs
		if inp.r? then r = NumberManager.makeNumber inp.r
		else
			deno = Proba.aleaEntreBornes 2,6
			num = Proba.aleaEntreBornes(1,2*deno)*Proba.aleaSign()
			inp.r = num+"/"+deno
			r = NumberManager.makeNumber {numerator:num, denominator:deno}
		gRtD = NumberManager.makeNumber(180).md(r,false).simplify()
		r = r.md(Trigo.pi(),false).simplify()

		if inp.d? then d = NumberManager.makeNumber inp.d
		else
			inp.d = (Proba.aleaEntreBornes 1,25)*15
			d = NumberManager.makeNumber inp.d
		gDtR = Trigo.degToRad d
		[
			new BEnonce { zones:[{
				body:"enonce"
				html:"<p>On donne $\\alpha = #{r.tex()}$ en radians. Il faut donner la mesure de $\\alpha$ en degrés.</p><p>On donne $\\beta = #{d.tex()}$ en degrés. Il faut donner la mesure de $\\beta$ en radians.</p>"
			}]}
			new BListe {
				data:data
				bareme:100
				title:"Conversions"
				liste:[{tag:"$\\alpha$", name:"rtd", description:"Mesure en degrés", good:gRtD}, {tag:"$\\beta$", name:"dtr", description:"Mesure en radians", good:gDtR}]
				aide: oHelp.trigo.rad_deg.concat oHelp.trigo.pi
				touches:["pi"]
			}
		]
