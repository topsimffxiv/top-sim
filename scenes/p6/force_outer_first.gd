extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p6_force_outer_first

func _on_pressed() -> void:
	Global.p6_force_outer_first = button_pressed
