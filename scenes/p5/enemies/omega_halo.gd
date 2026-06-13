extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func get_pos() -> Vector2:
	return Vector2(self.global_position.x, self.global_position.z)
	
func play_laser_blast():
	state_machine.start("definitely_idle", true)
	state_machine.travel("laser_blast")
	
func play_idle():
	state_machine.travel("definitely_idle")
