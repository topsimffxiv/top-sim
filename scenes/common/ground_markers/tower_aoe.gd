




extends GroundMarker
class_name TowerAoe

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_parameters(new_position: Vector3, radius: float, lifetime: float, color: Color) -> void :
	visible = true
	set_center_position(new_position)
	set_radius(radius)
	set_color(color)
	set_lifetime(lifetime)


func set_radius(radius: float) -> void :
	mesh_instance_3d.mesh.top_radius = radius
	mesh_instance_3d.mesh.bottom_radius = radius
	collision_shape_3d.shape.radius = radius
	set_grow_animation(radius)


func set_grow_animation(radius: float) -> void :
	var anim: Animation = animation_player.get_animation("grow_in")
	anim.track_set_key_value(0, 0, radius / 2)
	anim.track_set_key_value(0, 1, radius)
	anim.track_set_key_value(1, 0, radius / 2)
	anim.track_set_key_value(1, 1, radius)



func get_collisions() -> Array:
	var bodies_hit: = get_overlapping_bodies()

	return bodies_hit



func set_lifetime(lifetime: float, animation_delay: float = 0.0) -> void :
	await get_tree().create_timer(lifetime+animation_delay).timeout
	animation_player.play("fade_out")


func play_start_animation() -> void :
	animation_player.play("grow_in")
