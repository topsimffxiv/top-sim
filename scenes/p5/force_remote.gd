extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p5_force_remote

func _on_pressed() -> void:
	Global.p5_force_remote = button_pressed
	
	if Global.p5_force_remote:
		var b = get_parent().get_node("ForceMid")
		b.button_pressed = false
		Global.p5_force_mid = false
