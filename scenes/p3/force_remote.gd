extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p3_start_remote
	


func _on_pressed() -> void:
	Global.p3_start_remote = button_pressed
	
	var buttons = ["ForceDefam", "ForceStack", "ForceRemote", "ForceLocal"]
	
	for i in range(0,4):
		if buttons[i] == "ForceRemote":
			continue
		var button = get_parent().get_node(buttons[i])
		button.button_pressed = false
		
	Global.p3_start_defam = false
	Global.p3_start_stack = false
	Global.p3_start_local = false
	
