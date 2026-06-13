extends Node

class_name OPos

const CLEAVE_SPAWN_POS = [
	Vector3(16.617, 0.0, -16.617), Vector3(16.617, 0.0, 16.617), Vector3(-16.617, 0.0, 16.617), Vector3(-16.617, 0.0, -16.617), 
]

const LEFT_MONITOR_POS = {
	"bind1": Vector2(18.27, -25.57), "bind2": Vector2(-18.27, -25.57),
	"near": Vector2(0, 23.5), "far": Vector2(-23.5, 2.60), 
	"target1": Vector2(45.25, 4.0), "target2": Vector2(7.71, 44.73),
	"target3": Vector2(-7.71, 44.73), "target4": Vector2(-45.25, 4.0)
}

const RIGHT_MONITOR_POS = {
	"bind1": Vector2(18.27, 25.57), "bind2": Vector2(-18.27, 25.57),
	"near": Vector2(0, -23.5), "far": Vector2(-23.5, -2.60), 
	"target1": Vector2(45.25, -4.0), "target2": Vector2(7.71, -44.73),
	"target3": Vector2(-7.71, -44.73), "target4": Vector2(-45.25, -4.0)
}

const BLASTER_POS = {
	"near": Vector2(-23.5, 0), "far": Vector2(-6.0, -23.5),
	"bind1": Vector2(39.15, -23.5), "bind2": Vector2(39.15, 23.5),
	"target1": Vector2(-8.0, -45.0), "target2": Vector2(-45.5, -8.0),
	"target3": Vector2(-45.5, 8.0), "target4": Vector2(-8.0, 45.0),
	"bind1_adjust": Vector2(44.67, 10.62), "bind2_adjust": Vector2(44.67, -10.62)
}

const ADJUST_BLASTER_POS = {
	"far": Vector2(0, -23.5), "target1": Vector2(0, -45.0), "target4": Vector2(0, 45.0)
}
