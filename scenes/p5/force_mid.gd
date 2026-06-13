extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p5_force_mid

func _on_pressed() -> void:
	Global.p5_force_mid = button_pressed
	
	if Global.p5_force_mid:
		var b = get_parent().get_node("ForceRemote")
		b.button_pressed = false
		Global.p5_force_remote = false
