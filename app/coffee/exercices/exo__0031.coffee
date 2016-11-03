
Exercice.liste.push
	id:31
	title: "Conversion entre degré et radians"
	description: "Transformer une mesure en degrés en une mesure en radians et réciproquement."
	keyWords:["Géométrie", "Trigonométrie", "Seconde"]
	init: (data) ->
		inp = data.inputs
		if inp.r? then r = mM.toNumber inp.r
		else
			r = mM.alea.number { values:{min:1, max:12, sign:true}, denominator:{min:2, max:6} }
			inp.r = String r
		r = mM.exec [r, "pi", "*"], {simplify:true}
		gRtD = mM.trigo.radToDeg r

		if inp.d? then d = mM.toNumber inp.d
		else
			d = mM.alea.number { min:1, max:25, coeff:15 }
			inp.d = String d
		gDtR = mM.trigo.degToRad d
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
