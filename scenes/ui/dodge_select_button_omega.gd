




extends OptionButton


func _ready() -> void :
	self.selected = Global.p5_omega_selected_dodge


func _on_item_selected(index: int) -> void :
	Global.p5_omega_selected_dodge = index
