extends CheckButton

func _ready() -> void :
	self.button_pressed = Global.p2_hide_bots
	


func _on_pressed() -> void:
	Global.p2_hide_bots = button_pressed
