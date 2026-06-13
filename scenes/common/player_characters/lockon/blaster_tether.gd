




extends Area3D
class_name BlasterTether

signal body_intercepted(tether: BlasterTether, body: Node3D)

const CHAIN_HEIGHT: = Vector3(0, 2.0, 0)
const OMEGA_HEIGHT: = Vector3(0, 10.0, 0)

var debug: = false

@onready var target: Node3D
@onready var source: Node = $".."
@onready var collisionshape: CollisionShape3D = %BlasterTetherCollision
@onready var tethermesh: MeshInstance3D = %BlasterTetherMesh

@export var active: = false

var dist_to_target: float
var chain_active: = true
var adjusted_source_global: Vector3
var adjusted_target_global: Vector3

var allow_pass: bool

var size: float

var frame_counter = 0

func _ready():
	set_size(size)

func _physics_process(_delta: float) -> void :
	

	if !active or target == null:
		return

	adjusted_source_global = source.global_position + OMEGA_HEIGHT
	adjusted_target_global = target.global_position + CHAIN_HEIGHT
	self.look_at_from_position(adjusted_source_global, adjusted_target_global)
	dist_to_target = adjusted_source_global.distance_to(adjusted_target_global)
	tethermesh.scale = Vector3(1.0 / source.scale.x, 1.0 / source.scale.y, 1.0 / source.scale.z * dist_to_target)
	tethermesh.global_position = adjusted_source_global.lerp(adjusted_target_global, 0.5)
	collisionshape.shape.height = 1.0 / source.scale.z * dist_to_target
	collisionshape.global_position = adjusted_source_global.lerp(adjusted_target_global, 0.5)
	if debug:
		print(dist_to_target)


func set_variables(new_source, new_target, new_size, _allow_pass = true):
	source = new_source
	target = new_target
	adjusted_source_global = source.global_position + OMEGA_HEIGHT
	adjusted_target_global = target.global_position + CHAIN_HEIGHT
	dist_to_target = adjusted_source_global.distance_to(adjusted_target_global)
	size = new_size
	allow_pass = _allow_pass
	

func set_chain_active(is_active: bool) -> void :
	chain_active = is_active


func set_size(new_size: float) -> void :
	tethermesh.mesh.size.x = new_size
	tethermesh.mesh.size.y = new_size


func set_target(new_target: Node3D) -> void :
	target = new_target


func set_source(new_source: Node3D) -> void :
	source = new_source


func get_dist_to_target() -> float:
	return dist_to_target


func _on_body_entered(body: Node3D) -> void:
	if body != target:
		body_intercepted.emit(self, body)
