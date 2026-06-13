extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func play_starboard():
	state_machine.travel("starboard")
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	tween.tween_property(self, "global_rotation", self.global_rotation + Vector3(0, -PI, 0), 0.3)
	self.get_node("StarboardOrbs").visible = false
	
func play_larboard():
	state_machine.travel("larboard")
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	tween.tween_property(self, "global_rotation", self.global_rotation + Vector3(0, PI, 0), 0.3)
	self.get_node("LarboardOrbs").visible = false
	
func play_pantokrator():
	state_machine.travel("start_panto")
	await $AnimationPlayer.animation_finished
	state_machine.travel("idle_pantokrator")
	
func play_spawn_fists():
	state_machine.travel("spawn_fists")
	
func play_arrive():
	visible = false
	state_machine.travel("fall_in")
	await get_tree().create_timer(0.35).timeout
	visible = true
	
func play_leave():
	state_machine.travel("leave")
	
func play_end_blaster():
	state_machine.travel("blaster_end")
	
func play_end_program_loop():
	state_machine.travel("program_loop_end")

func show_larboard_orbs():
	self.get_node("LarboardOrbs").visible = true
	
func show_starboard_orbs():
	self.get_node("StarboardOrbs").visible = true
