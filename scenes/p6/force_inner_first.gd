extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p6_force_inner_first

func _on_pressed() -> void:
	Global.p6_force_inner_first = button_pressed
