extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p2_force_stack_flex
	


func _on_pressed() -> void:
	Global.p2_force_stack_flex = button_pressed
	
