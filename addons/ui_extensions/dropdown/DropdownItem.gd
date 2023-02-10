# UI Extension Filter Dropdown Item : MIT License
# @author Vladimir Petrenko
extends Object
class_name DropdownItem

var value
var text: String
var tooltip: String
var icon: Texture2D

func _init(ivalue, itext: String, itooltip: String = "", iicon: Texture2D = null) -> void:
	self.value = ivalue
	self.text = itext
	self.tooltip = itooltip
	self.icon = iicon
