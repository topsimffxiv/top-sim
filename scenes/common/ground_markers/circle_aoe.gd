




extends GroundMarker
class_name CircleAoe

signal circle_body_entered(body: CharacterBody3D, circle: CircleAoe)
signal circle_area_entered(area: Area3D, spell_name: String)
var _radius: float

func set_parameters(new_position: Vector3, radius: float, lifetime: float, 
color: Color, fail_conditions: Array = [], check_end: bool = false, animation_delay: float = 0.0) -> void :
	set_center_position(new_position)
	set_radius(radius)
	set_color(color)
	set_lifetime(lifetime)
	self._animation_delay = animation_delay
	if check_end:
		check_at_end()
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_radius(radius: float) -> void :
	_radius = radius
	mesh_instance_3d.mesh.top_radius = radius
	mesh_instance_3d.mesh.bottom_radius = radius
	collision_shape_3d.shape.radius = radius











func play_start_animation() -> void :
	await get_tree().create_timer(_animation_delay).timeout
	mesh_instance_3d.mesh.top_radius = _radius / 2
	mesh_instance_3d.mesh.bottom_radius = _radius / 2
	var tween: = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "mesh_instance_3d:mesh:top_radius", _radius, 0.2)
	tween.tween_property(self, "mesh_instance_3d:mesh:bottom_radius", _radius, 0.2)


func _on_body_entered(body: CharacterBody3D) -> void :
	circle_body_entered.emit(body, self)


func _on_area_entered(area: Area3D) -> void :
	circle_area_entered.emit(area, spell_name)
