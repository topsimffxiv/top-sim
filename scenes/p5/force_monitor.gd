extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p5_force_monitor

func _on_pressed() -> void:
	Global.p5_force_monitor = button_pressed
