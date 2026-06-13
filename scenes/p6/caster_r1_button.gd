extends CheckButton


func _ready() -> void :
	Global.p6_caster_r1 = SavedVariables.save_data["settings"]["caster_r1"]
	button_pressed = SavedVariables.save_data["settings"]["caster_r1"]


func _on_pressed() -> void :
	Global.p6_caster_r1 = button_pressed
	GameEvents.emit_variable_saved("settings", "caster_r1", button_pressed)
