extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p5_force_beyond_defense

func _on_pressed() -> void:
	Global.p5_force_beyond_defense = button_pressed
