class CExams extends Collection
	url:"./api/exams"
	constructor: (liste, @parent) ->
		@model = MExam
		super(liste)
