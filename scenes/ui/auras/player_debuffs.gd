




extends MovableCanvasLayer

@onready var move_ui_bg: Panel = %MoveUIBG


func _ready():
    section_key = "player_debuffs"
    GameEvents.ui_ready.connect(on_ui_ready)


func _on_margin_container_gui_input(event: InputEvent) -> void :
    if not Global.is_moving_ui:
        return
    if event is InputEventMouseButton:
        on_container_mouse_button_event(event)


func on_move_ui_on():
    move_ui_bg.show()


func on_move_ui_off():
    move_ui_bg.hide()
