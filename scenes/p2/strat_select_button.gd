




extends OptionButton


func _ready() -> void :
	self.selected = SavedVariables.save_data["settings"]["p2_lr_strat"]


func _on_item_selected(index: int) -> void :
	GameEvents.emit_variable_saved("settings", "p2_lr_strat", index)
