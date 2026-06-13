extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p2_force_mid
	


func _on_pressed() -> void:
	Global.p2_force_mid = button_pressed
	
	if Global.p2_force_remote:
		var b = get_parent().get_node("ForceRemoteButton")
		b.button_pressed = false
		Global.p2_force_remote = false
