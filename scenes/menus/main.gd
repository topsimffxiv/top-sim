




extends Node

var seq_scene_paths: = {
	0: "res://scenes/p2/p2_party_synergy.tscn", # looper
	1: "res://scenes/p2/p2_party_synergy.tscn", # pantokrator
	2: "res://scenes/p2/p2_party_synergy.tscn", # party synergy
	3: "res://scenes/p2/p2_party_synergy.tscn", # limitless synergy
	4: "res://scenes/p2/p2_party_synergy.tscn", # p3 transition
	5: "res://scenes/p3/p3_hello_world.tscn", # hello world
	6: "res://scenes/p3/p3_monitors.tscn", # monitors
	7: "res://scenes/p2/p2_party_synergy.tscn", # blue screen
	8: "res://scenes/p5/p5_delta.tscn", # delta
	9: "res://scenes/p5/p5_sigma.tscn", # sigma
	10: "res://scenes/p5/p5_omega.tscn", # omega
	11: "res://scenes/p6/p6_main.tscn", # p6 hub
}


func _ready() -> void :
	var selected_seq: int = SavedVariables.get_data("settings", "selected_seq")
	var loaded_scene = load(seq_scene_paths[selected_seq])
	await get_tree().process_frame
	get_tree().change_scene_to_packed(loaded_scene)
