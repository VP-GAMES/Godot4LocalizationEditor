# Single  locale for LocalizationEditor : MIT License
# @author Vladimir Petrenko
extends Object
class_name LocalizationLocaleSingle

var code: String
var name: String

func _init(pcode: String,  pname: String):
	code = pcode
	name = pname
