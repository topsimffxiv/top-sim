




extends MeshInstance3D
class_name LaserHandTether



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

var frame_counter = 0

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


func set_variables(new_source, new_target, new_size):
	source = new_source
	target = new_target
	mesh.size.x = new_size
	mesh.size.y = new_size
	dist_to_target = source.global_position.distance_to(target.global_position)

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
