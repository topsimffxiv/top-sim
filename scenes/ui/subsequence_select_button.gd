extends OptionButton

func _ready() -> void :
	selected = Global.p6_selected_seq


func _on_item_selected(index: int) -> void :
	Global.p6_selected_seq = index
