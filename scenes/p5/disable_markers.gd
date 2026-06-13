extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p5_disable_markers

func _on_pressed() -> void:
	Global.p5_disable_markers = button_pressed
