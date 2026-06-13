extends GroundMarker
class_name RedRotTower

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_parameters(tower_rotation: float, center_position = Vector3(32.5, 0, 0), radius = 15.0, _lifetime = 0.2) -> void :
	visible = true
	set_center_position(center_position)
	set_red_tower_rotation(tower_rotation)
	set_radius(radius)
	#set_lifetime(lifetime)
	
func set_red_tower_rotation(tower_rotation: float) -> void :
	self.position = self.position.rotated(Vector3.UP, -tower_rotation)

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

func get_pos() -> Vector2:
	return Vector2(self.global_position.x, self.global_position.z)


#func set_lifetime(lifetime: float) -> void :
	#await get_tree().create_timer(lifetime).timeout
	#animation_player.play("fade_out")


func play_start_animation() -> void :
	animation_player.play("grow_in")
	$AnimatedSprite3D.play()
