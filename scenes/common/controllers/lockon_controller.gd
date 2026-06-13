













extends Node
class_name LockonController

const CRITICAL_PERFORMANCE_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/critical_performance_bug.tscn")
const CRITICAL_UNDERFLOW_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/critical_underflow_bug.tscn")

var res_paths: = {
	"PS_Cross": "res://scenes/common/player_characters/lockon/ps_cross.tscn", 
	"PS_Circle": "res://scenes/common/player_characters/lockon/ps_circle.tscn", 
	"PS_Square": "res://scenes/common/player_characters/lockon/ps_square.tscn", 
	"PS_Triangle": "res://scenes/common/player_characters/lockon/ps_triangle.tscn", 
	"Sharp_Target": "res://scenes/p5/lockon/sharp_target.tscn",
	"Stack_Marker": "res://scenes/common/player_characters/lockon/stack_marker.tscn",
	"Critical_Performance_Bug": "res://scenes/p3/lockon/critical_performance_bug.tscn", # blue
	"Critical_Underflow_Bug": "res://scenes/p3/lockon/critical_underflow_bug.tscn", # red
	"Left_Oversampled_Wave_Cannon": "res://scenes/p3/lockon/left_monitor.tscn", # left monitor
	"Right_Oversampled_Wave_Cannon": "res://scenes/p3/lockon/right_monitor.tscn", # right monitor
	"Target_1": "res://scenes/common/player_characters/lockon/markers/target_1.tscn",
	"Target_2": "res://scenes/common/player_characters/lockon/markers/target_2.tscn",
	"Target_3": "res://scenes/common/player_characters/lockon/markers/target_3.tscn",
	"Target_4": "res://scenes/common/player_characters/lockon/markers/target_4.tscn",
	"Target_5": "res://scenes/common/player_characters/lockon/markers/target_5.tscn",
	"Link_1": "res://scenes/common/player_characters/lockon/markers/link_1.tscn",
	"Link_2": "res://scenes/common/player_characters/lockon/markers/link_2.tscn",
	"Link_3": "res://scenes/common/player_characters/lockon/markers/link_3.tscn",
	"Ignore_1": "res://scenes/common/player_characters/lockon/markers/ignore_1.tscn",
	"Ignore_2": "res://scenes/common/player_characters/lockon/markers/ignore_2.tscn",
	"Mark_Triangle": "res://scenes/common/player_characters/lockon/markers/mark_triangle.tscn",
	"Mark_Plus":"res://scenes/common/player_characters/lockon/markers/mark_plus.tscn",
}

var lockon_node_path: = "Lockon"
var loaded_scenes: Dictionary

func pre_load(load_list: Array) -> void :
	for elem in load_list:
		ResourceLoader.load_threaded_request(res_paths[elem])



func add_marker(lockon_id: String, target: Node3D) -> Node3D:
	assert (target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	if !loaded_scenes.has(lockon_id):
		loaded_scenes[lockon_id] = ResourceLoader.load_threaded_get(res_paths[lockon_id])
	var new_marker: Node3D = loaded_scenes[lockon_id].instantiate()
	target.get_node(lockon_node_path).add_child(new_marker)
	return new_marker

func add_marker_rot(lockon_id: String, target: Node3D) -> Array: # mainly just for rot logic, adding in debuffs
	assert (target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	if !loaded_scenes.has(lockon_id):
		loaded_scenes[lockon_id] = ResourceLoader.load_threaded_get(res_paths[lockon_id])
	var new_marker: Node3D = loaded_scenes[lockon_id].instantiate()
	target.get_node(lockon_node_path).add_child(new_marker)
	new_marker.set_armed(target)
	var rot_signal
	#print("Generating signal and debuff for %s" % lockon_id)
	if lockon_id == "Critical_Performance_Bug" and !target.has_debuff("Performance Code Smell"):
		rot_signal = target.add_debuff(CRITICAL_PERFORMANCE_BUG, 27.0, false, "Critical Performance Bug")
	if lockon_id == "Critical_Underflow_Bug" and !target.has_debuff("Underflow Code Smell"):
		rot_signal = target.add_debuff(CRITICAL_UNDERFLOW_BUG, 27.0, false, "Critical Underflow Bug")
	
	var arr = [new_marker, rot_signal]
	
	return arr

func remove_marker(lockon_id: String, target: Node3D) -> bool:
	#print("removing %s" % lockon_id)
	assert (target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	var node_to_remove = target.get_node(lockon_node_path).get_node_or_null(lockon_id)
	if !node_to_remove:
		return false
	node_to_remove.queue_free()
	return true
