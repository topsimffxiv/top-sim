
extends CheckButton

signal toggle_bots_visible

func _ready() -> void :
	button_pressed = Global.p6_hide_bots


func _on_pressed() -> void :
	Global.p6_hide_bots = button_pressed
	toggle_bots_visible.emit()
	
func set_bots_visible() -> void:
	Global.p6_hide_bots = false
	button_pressed = false
	toggle_bots_visible.emit()
