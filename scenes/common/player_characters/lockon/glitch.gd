




extends MeshInstance3D
class_name Chain

signal add_vuln(chain_target: Node3D, chain_source: Node3D)
signal remove_vuln(chain_target: Node3D, chain_source: Node3D)

const CHAIN_HEIGHT: = 2.0

var debug: = false

@onready var target: Node3D
@onready var source: Node = $".."

@export var active: = false

var dist_to_target: float
var min_length: = 0.0
var max_length: = 9999
var chain_active: = true
var chain_stretched := true
var debuff_present := true
var update_vuln := true

func _physics_process(_delta: float) -> void :
	if !active or target == null:
		return

	look_at_from_position(source.global_position, target.global_position)
	dist_to_target = source.global_position.distance_to(target.global_position)
	scale = Vector3(1.0 / source.scale.x, 1.0 / source.scale.y, 1.0 / source.scale.z * dist_to_target)
	global_position = source.global_position.lerp(target.global_position, 0.5)
	global_position.y = CHAIN_HEIGHT
	if debug:
		print(dist_to_target)
	
	if update_vuln:
		if debuff_present:
			if dist_to_target >= min_length and dist_to_target <= max_length:
				remove_vuln.emit(target, source)
				debuff_present = false
		else:
			if dist_to_target < min_length or dist_to_target > max_length:
				add_vuln.emit(target, source)
				debuff_present = true


func set_variables(new_source, new_target, new_max_length, new_min_length, new_size) -> bool : # returns true if vuln must be added immediately
	source = new_source
	target = new_target
	max_length = new_max_length
	min_length = new_min_length
	mesh.size.x = new_size
	mesh.size.y = new_size
	dist_to_target = source.global_position.distance_to(target.global_position)
	if dist_to_target < min_length or dist_to_target > max_length:
		debuff_present = true
	else: 
		debuff_present = false
	return debuff_present

func set_vuln_start() -> void :
	add_vuln.emit(target, source)

func set_chain_active(is_active: bool) -> void :
	chain_active = is_active


func set_size(new_size: float) -> void :
	mesh.size.x = new_size
	mesh.size.y = new_size


func set_target(new_target: Node3D) -> void :
	target = new_target


func set_source(new_source: Node3D) -> void :
	source = new_source


func get_dist_to_target() -> float:
	return dist_to_target

func erase_vuln() -> void:
	update_vuln = false
	if debuff_present:
		remove_vuln.emit(target, source)
