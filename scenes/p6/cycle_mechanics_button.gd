extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p6_continue_cycle

func _on_pressed() -> void:
	Global.p6_continue_cycle = button_pressed
