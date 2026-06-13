extends Area3D

signal collision_check(bodies: Array)

var frame_counter: int = 0
const CHECK_INTERVAL: int = 10

func _physics_process(_delta: float):
	frame_counter += 1
	if frame_counter % CHECK_INTERVAL == 0:
		frame_counter = 0
		
		var bodies = get_overlapping_bodies()
		collision_check.emit(bodies)
