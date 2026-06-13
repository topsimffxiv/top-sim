




extends Node

class_name WaymarkController


@export var waymark_scene: PackedScene

@export var arena_waymark_node: Node3D

var wm_scene: Waymarks
var menu_slot_keys: = ["preset_1", "preset_2", "preset_3", "custom_1", "custom_2"]


func _ready() -> void :
	var wm_positions

	if Global.waymarks["current"].is_empty():
		var active_key = SavedVariables.save_data["waymarks"]["active"]
		if active_key.contains("custom"):
			wm_positions = SavedVariables.save_data["waymarks"][active_key]
		else:
			wm_positions = Global.waymarks[active_key]
		Global.waymarks["current"] = wm_positions
	else:
		wm_positions = Global.waymarks["current"]

	wm_scene = waymark_scene.instantiate()
	arena_waymark_node.add_child(wm_scene)
	wm_scene.set_waymarks(wm_positions)


func move_waymark(wm_key: String, new_pos: Vector2):
	wm_scene.move_waymark(wm_key, new_pos)


func clear_wm(wm_key: String):
	wm_scene.hide_wm(wm_key)


func clear_all_wm():
	wm_scene.hide_all()


func set_preset_markers(preset_slot: int):

	if preset_slot < 3:
		wm_scene.set_waymarks(Global.waymarks[menu_slot_keys[preset_slot]])

	else:
		wm_scene.set_waymarks(SavedVariables.save_data["waymarks"][menu_slot_keys[preset_slot]])

	GameEvents.emit_variable_saved("waymarks", "active", menu_slot_keys[preset_slot])


func save_custom_preset(preset_slot: int):
	assert (preset_slot > 2, "Error. Tried to save Waymark preset to invalid index.")
	GameEvents.emit_variable_saved("waymarks", "active", menu_slot_keys[preset_slot])
	GameEvents.emit_variable_saved("waymarks", menu_slot_keys[preset_slot], wm_scene.get_active_wm_positions())
