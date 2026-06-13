







extends PlayableCharacter
class_name Player

signal target_changed(target: Node3D)

var debug: = false



@onready var player_movement_controller: PlayerMovementController = %PlayerMovementController
@onready var camera: Camera3D = %Camera3D











func set_parameters(new_role_key: String, new_model_scene: PackedScene, 
	spawn_position: Vector3) -> void :
	model_scene = new_model_scene
	role_key = new_role_key
	position = spawn_position
	is_player_character = true


func set_model_meta(meta_data) -> void :
	player_movement_controller.xiv_model = meta_data



func handle_left_click(mouse_pos: Vector2) -> void :
	var ray_result: Dictionary = camera.get_first_ray_collision(mouse_pos)
	if debug:
		print(mouse_pos)
		print(ray_result)
	if ray_result.is_empty():
		target_changed.emit(null)
		return
	var collider: Node3D = ray_result["collider"]
	if collider is Area3D:
		collider = collider.get_parent_node_3d()
	target_changed.emit(collider)


func reset_movement():
	player_movement_controller.reset_player_movement()














func get_camera() -> Camera3D:
	return camera






func freeze_player() -> void :
	player_movement_controller.is_frozen = true
	anim_tree.set("parameters/conditions/idle", true)


func unfreeze_player() -> void :
	player_movement_controller.is_frozen = false


func is_player() -> bool:
	return true


func dash() -> void :
	player_movement_controller.dash()



func arms_length() -> void :
	player_movement_controller.arms_length()



func sprint() -> void :
	player_movement_controller.sprint()


func is_player_frozen() -> bool:
	return player_movement_controller.is_frozen
