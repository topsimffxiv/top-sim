




extends OptionButton


func _ready() -> void :
	self.selected = Global.p5_sigma_selected_debuff


func _on_item_selected(index: int) -> void :
	Global.p5_sigma_selected_debuff = index
