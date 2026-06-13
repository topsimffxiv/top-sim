extends Node3D

var bodies: Array  # list of bodies inside of collision box
var framecount = 0
var holder
	
func _process(_delta):

	self.global_rotation.y = holder.get_model_rotation().y + PI

func set_holder(body):
	holder = body
	bodies.append(holder)

func _on_collision_check(bods: Array) -> void:
	bodies = bods
	bodies.erase(holder)
