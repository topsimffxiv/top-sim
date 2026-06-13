




extends OptionButton


func _ready() -> void :
	selected = SavedVariables.save_data["settings"]["player_role"]


func _on_item_selected(index: int) -> void :
	GameEvents.emit_variable_saved("settings", "player_role", index)
