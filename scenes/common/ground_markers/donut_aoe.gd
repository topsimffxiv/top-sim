




extends GroundMarker
class_name DonutAoe

var _inner_radius: float

func set_parameters(new_position: Vector3, inner_radius: float, outer_radius: float, 
	 lifetime: float, color: Color, fail_conditions: Array = []) -> void :
	is_donut = true
	donut_inner_radius = inner_radius
	set_center_position(new_position)
	set_radius(inner_radius, outer_radius)
	set_color(color)
	set_lifetime(lifetime)
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_radius(inner_radius: float, outer_radius: float) -> void :
	mesh_instance_3d.mesh.top_radius = outer_radius
	mesh_instance_3d.mesh.bottom_radius = outer_radius
	var shader_factor: = (inner_radius / outer_radius) / 4.0
	mesh_instance_3d.mesh.material.set_shader_parameter("size", shader_factor)
	collision_shape_3d.shape.radius = outer_radius
	_inner_radius = inner_radius


func set_color(color: Color) -> void :
	mesh_instance_3d.mesh.material.set_shader_parameter("color", color)



func get_collisions() -> Array:

	var all_bodies: = get_overlapping_bodies()
	var bodies_hit: = []

	for body in all_bodies:
		var pos: = body.global_position
		if pos.distance_squared_to(global_position) > _inner_radius ** 2:
			bodies_hit.append(body)
	return bodies_hit
