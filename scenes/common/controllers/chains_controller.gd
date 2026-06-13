




extends Node
class_name ChainsController

signal patch_activated(target: Node3D, source: Node3D)

const CHAIN_WIDTH: = 0.15
const VULN_UP = preload("res://scenes/ui/auras/debuff_icons/common/vuln_up.tscn")
const MAGIC_VULN_STACK = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln_stack.tscn")
const THRICE_COME_RUIN = preload("res://scenes/ui/auras/debuff_icons/common/thrice_come_ruin.tscn")

var res_paths = {
	"glitch": "res://scenes/common/player_characters/lockon/glitch.tscn",
	"local_code_smell": "res://scenes/common/player_characters/lockon/local_code_smell.tscn",
	"local_regression": "res://scenes/common/player_characters/lockon/local_regression.tscn",
	"remote_code_smell": "res://scenes/common/player_characters/lockon/remote_code_smell.tscn",
	"remote_regression": "res://scenes/common/player_characters/lockon/remote_regression.tscn",
	"laser_hand_tether": "res://scenes/common/player_characters/lockon/laser_hand.tscn",
	"blaster_tether": "res://scenes/common/player_characters/lockon/blaster_tether.tscn"
}

var chain_scene: PackedScene
var laser_hand_tether_scene: PackedScene
var local_code_smell_scene: PackedScene
var local_regression_scene: PackedScene
var remote_code_smell_scene: PackedScene
var remote_regression_scene: PackedScene
var blaster_tether_scene: PackedScene
var active_chains: Array
var fail_list: FailList

func pre_load(path_indices = ["glitch"]) -> void :
	for elem in path_indices:
		ResourceLoader.load_threaded_request(res_paths[elem], "PackedScene")
	fail_list = get_tree().get_first_node_in_group("fail_list")

func spawn_glitch(source: Node3D, target: Node3D, max_length: float = 9999, 
	min_length: float = 0.0, size: float = CHAIN_WIDTH) -> Chain:
	if !chain_scene:
		chain_scene = ResourceLoader.load_threaded_get(res_paths["glitch"])
	var new_chain: Chain = chain_scene.instantiate()
	var set_vuln = new_chain.set_variables(source, target, max_length, min_length, size)
	new_chain.visible = true
	new_chain.active = true
	source.add_child(new_chain)
	active_chains.append(new_chain)
	new_chain.add_vuln.connect(on_add_vuln)
	new_chain.remove_vuln.connect(on_remove_vuln)
	if set_vuln :
		new_chain.set_vuln_start()
	return new_chain
	
func on_add_vuln(_target, _source) -> void :
	_target.add_debuff(VULN_UP, 10000.0, false, "Vulnerability Up")
	_source.add_debuff(VULN_UP, 10000.0, false, "Vulnerability Up")
	
func on_remove_vuln(_target, _source) -> void :
	_target.remove_debuff("Vulnerability Up")
	_source.remove_debuff("Vulnerability Up")

func spawn_blaster_tether(source: Node3D, target: Node3D, _allow_pass: bool = true) -> BlasterTether :
	if !blaster_tether_scene:
		blaster_tether_scene = ResourceLoader.load_threaded_get(res_paths["blaster_tether"])
	var new_chain: BlasterTether = blaster_tether_scene.instantiate()
	new_chain.set_variables(source, target, CHAIN_WIDTH*1.3, _allow_pass)
	new_chain.active = true
	source.add_child(new_chain)
	active_chains.append(new_chain)
	
	return new_chain

func spawn_laser_hand_tether(source: Node3D, target: Node3D):
	if !laser_hand_tether_scene:
		laser_hand_tether_scene = ResourceLoader.load_threaded_get(res_paths["laser_hand_tether"])
	var new_chain: LaserHandTether = laser_hand_tether_scene.instantiate()
	new_chain.set_variables(source, target, CHAIN_WIDTH/1.5)
	new_chain.visible = false
	new_chain.active = true
	source.add_child(new_chain)
	active_chains.append(new_chain)

	return new_chain


func spawn_local_code_smell(source: Node3D, target: Node3D, duration: float) -> LocalCodeSmell:
	if !local_code_smell_scene:
		local_code_smell_scene = ResourceLoader.load_threaded_get(res_paths["local_code_smell"])
	var new_chain: LocalCodeSmell = local_code_smell_scene.instantiate()
	new_chain.set_variables(source, target)
	new_chain.visible = duration <= 20.0
	source.add_child(new_chain)
	active_chains.append(new_chain)
	return new_chain
	
func spawn_local_regression(source: Node3D, target: Node3D) -> LocalRegression:
	if !local_regression_scene:
		local_regression_scene = ResourceLoader.load_threaded_get(res_paths["local_regression"])
	var new_chain: LocalRegression = local_regression_scene.instantiate()
	new_chain.set_variables(source, target)
	new_chain.visible = true
	source.add_child(new_chain)
	active_chains.append(new_chain)
	new_chain.local_regression_squeezed.connect(on_local_regression_squeezed)
	
	return new_chain
	
func on_local_regression_squeezed(_target, _source, stacks, chain) -> void :
	remove_chain(chain)
	_target.remove_debuff("Local Regression")
	_source.remove_debuff("Local Regression")
	for i in range(stacks):
		_target.add_debuff(MAGIC_VULN_STACK, 1.0, true, "Stacking Magic Vulnerability Up")
		_target.add_debuff(THRICE_COME_RUIN, 1.0, true, "Thrice Come Ruin")
		_source.add_debuff(MAGIC_VULN_STACK, 1.0, true, "Stacking Magic Vulnerability Up")
		_source.add_debuff(THRICE_COME_RUIN, 1.0, true, "Thrice Come Ruin")
	patch_activated.emit(_target, _source)
	
func spawn_remote_code_smell(source: Node3D, target: Node3D, duration: float) -> RemoteCodeSmell:
	if !remote_code_smell_scene:
		remote_code_smell_scene = ResourceLoader.load_threaded_get(res_paths["remote_code_smell"])
	var new_chain: RemoteCodeSmell = remote_code_smell_scene.instantiate()
	new_chain.set_variables(source, target)
	new_chain.visible = duration <= 20.0
	source.add_child(new_chain)
	active_chains.append(new_chain)
	return new_chain
	
func spawn_remote_regression(source: Node3D, target: Node3D) -> RemoteRegression:
	if !remote_regression_scene:
		remote_regression_scene = ResourceLoader.load_threaded_get(res_paths["remote_regression"])

	var new_chain: RemoteRegression = remote_regression_scene.instantiate()
	new_chain.set_variables(source, target)
	new_chain.visible = true
	source.add_child(new_chain)
	active_chains.append(new_chain)
	new_chain.remote_regression_stretched.connect(on_remote_regression_stretched)
	
	return new_chain

func on_remote_regression_stretched(_target, _source, stacks, chain) -> void :
	remove_chain(chain)
	_target.remove_debuff("Remote Regression")
	_source.remove_debuff("Remote Regression")
	if _target.has_debuff("Magic Vulnerability Up"):
		fail_list.add_fail("Remote tether popped too soon: %s and %s" % [_target, _source])
		
	for i in range(stacks):
		_target.add_debuff(MAGIC_VULN_STACK, 1.0, true, "Stacking Magic Vulnerability Up")
		_target.add_debuff(THRICE_COME_RUIN, 1.0, true, "Thrice Come Ruin")
		_source.add_debuff(MAGIC_VULN_STACK, 1.0, true, "Stacking Magic Vulnerability Up")
		_source.add_debuff(THRICE_COME_RUIN, 1.0, true, "Thrice Come Ruin")
	patch_activated.emit(_target, _source)



func remove_chain(chain) -> void :	
	for c in active_chains:
		if c == chain:
			c.queue_free()


func remove_all_chains() -> void :
	for i in active_chains.size():
		var chain: Chain = active_chains.pop_back()
		chain.queue_free()
