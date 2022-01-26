# UI Extension Filter Dropdown Item : MIT License
# @author Vladimir Petrenko
extends Object
class_name DropdownItem

var text: String
var value
var tooltip: String
var icon: Texture2D

func _init(itext: String, ivalue, itooltip: String = "", iicon: Texture2D = null) -> void:
	self.text = itext
	self.value = ivalue
	self.tooltip = itooltip
	self.icon = iicon
