extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p3_force_monitor

func _on_pressed() -> void:
	Global.p3_force_monitor = button_pressed
	
	if Global.p3_force_nothing:
		var b = get_parent().get_node("ForceNothing")
		b.button_pressed = false
		Global.p3_force_nothing = false
