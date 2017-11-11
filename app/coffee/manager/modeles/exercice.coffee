class MExercice extends SimpleModel
	_glyph: "glyphicon-edi"
	tex_exists:false
	defaultValues: -> { title:"", description:"", keyWords:null }
	parse: ->
		if @keyWords isnt null then @searchValue = (@title+";"+@description+";"+@keyWords.join(";")).toLowerCase()
		else @searchValue = (@title+";"+@description).toLowerCase()
		if @tex? then @tex_exists = true
	match: (filter) -> filter.reg?.test(@searchValue) isnt false
