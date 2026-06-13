extends Node3D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var side_orbs: Node3D = $SideOrbs
@onready var fb_orbs: Node3D = $FBOrbs

var casting: bool
var target
var target_name

# TODO: add rotation to face Tank 1 between casts
func get_model_rotation() -> Vector3:
	return self.global_rotation + Vector3(0, PI, 0)
	

func play_idle():
	state_machine.travel("neutral_idle")
	
func play_auto_attack():
	state_machine.travel("auto_attack")
	
func play_start_cast():
	casting = true
	state_machine.travel("generic_cast_idle")
	
func play_finish_hello_world_cast():
	state_machine.travel("hello_world_cast_end")
	state_machine.travel("neutral_idle")
	await $AnimationPlayer.animation_finished
	casting = false

func play_finish_latent_defect_cast():
	state_machine.travel("latent_defect_cast_end")
	await $AnimationPlayer.animation_finished

func play_left_monitor():
	state_machine.travel("start_left_monitor")
	await get_tree().create_timer(9.5).timeout
	state_machine.travel("end_left_monitor")
	
func play_right_monitor():
	state_machine.travel("start_right_monitor")
	await get_tree().create_timer(9.5).timeout
	state_machine.travel("end_right_monitor")

func play_wave_cannon_p5():
	state_machine.travel("start_p4_cast")
	await get_tree().create_timer(7.70).timeout
	state_machine.travel("end_p4_cast")
	
func play_diffuse_fb_idle():
	state_machine.travel("idle_fb_diffuse")
	await get_tree().create_timer(1.37).timeout
	fb_orbs.visible = true
	
func play_diffuse_fb_end():
	state_machine.travel("end_fb_diffuse")
	await get_tree().create_timer(2.0).timeout
	fb_orbs.visible = false
	
func play_diffuse_fb_instant():
	state_machine.travel("end_fb_diffuse")
	
func play_diffuse_side_idle():
	state_machine.travel("idle_side_diffuse")
	await get_tree().create_timer(1.37).timeout
	side_orbs.visible = true
	
func play_diffuse_side_end():
	state_machine.travel("end_side_diffuse")
	await get_tree().create_timer(2.0).timeout
	side_orbs.visible = false
	
	
func play_diffuse_side_instant():
	state_machine.travel("end_side_diffuse")
