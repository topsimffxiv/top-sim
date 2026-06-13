extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p3_markers

func _on_pressed() -> void:
	Global.p3_markers = button_pressed
