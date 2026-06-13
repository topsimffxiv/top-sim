extends CheckButton


func _ready() -> void :
	self.button_pressed = Global.p3_blue_is_defamation

func _on_pressed() -> void:
	Global.p3_blue_is_defamation = button_pressed
	
	if Global.p3_red_is_defamation:
		var b = get_parent().get_node("ForceRedDefamation")
		b.button_pressed = false
		Global.p3_red_is_defamation = false
