extends CheckButton


func _on_ready() -> void :
	self.button_pressed = Global.p2_force_remote

func _on_pressed() -> void:
	Global.p2_force_remote = button_pressed
	
	if Global.force_mid:
		var b = get_parent().get_node("ForceRedDefamation")
		b.button_pressed = false
		Global.p2_force_mid = false
