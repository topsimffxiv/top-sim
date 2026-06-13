




extends Node3D

class_name LooperSoloTower


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_area_3d: Area3D = $CollisionArea3D
@onready var outer_mesh_highlight: MeshInstance3D = $OuterMeshHighlight
@onready var upper_glow_ring: CSGTorus3D = $UpperGlowRing

enum SoakState{UNDER, SOAKED, OVER}

var bodies_required: = 1
var soaked: = SoakState.UNDER
var bodies: = 0
var lifetime: = 10.0
var bodies_array: = []


func set_parameters(pos: Vector3, _lifetime: float):
	self.global_position = pos
	lifetime = _lifetime



func play_start_animation() -> void :
	animation_player.play("orb_drop")




func get_bodies() -> Array:
	return bodies_array


func set_bodies_required(new_bodies_required: int) -> void :
	bodies_required = new_bodies_required
	check_bodies()


func _on_collision_area_3d_body_entered(body: Node3D) -> void :
	if body.has_debuff("Looper"):
		bodies += 1
		bodies_array.append(body)
		check_bodies()


func _on_collision_area_3d_body_exited(body: Node3D) -> void :
	if body.has_debuff("Looper"):
		bodies -= 1
		bodies_array.erase(body)
		check_bodies()


func check_bodies() -> void :
	if bodies < bodies_required:
		outer_mesh_highlight.visible = false
		upper_glow_ring.visible = false
		soaked = SoakState.UNDER
	elif bodies == bodies_required:
		outer_mesh_highlight.visible = true
		upper_glow_ring.visible = true
		soaked = SoakState.SOAKED
	else:
		outer_mesh_highlight.visible = true
		upper_glow_ring.visible = true
		soaked = SoakState.OVER
