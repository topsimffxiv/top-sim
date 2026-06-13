extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p3_force_nothing

func _on_pressed() -> void:
	Global.p3_force_nothing = button_pressed
	
	if Global.p3_force_monitor:
		var b = get_parent().get_node("ForceMonitor")
		b.button_pressed = false
		Global.p3_force_monitor = false
