extends Node3D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var is_facing: bool = false
var target: PlayableCharacter

func _physics_process(_delta: float) -> void:
	if !is_facing:
		return
	
	self.look_at(target.global_position, Vector3(0, 1, 0), true)
	
	

func start_facing(_target):
	target = _target
	is_facing = true
	
func stop_facing():
	is_facing = false

func get_pos() -> Vector2:
	return Vector2(self.global_position.x, self.global_position.z)
	
func play_cosmo_arrow():
	state_machine.travel("cosmo_arrow_start")
	await get_tree().create_timer(5.7).timeout
	state_machine.travel("cosmo_arrow_end")
	
func play_cosmo_dive():
	state_machine.travel("cosmo_dive_start")
	await get_tree().create_timer(7.7-2.9).timeout
	state_machine.travel("cosmo_dive_end")

func play_uwc():
	state_machine.travel("uwc_start")
	await get_tree().create_timer(4.7).timeout
	state_machine.travel("uwc_end")

func play_wc_stack():
	state_machine.travel("wc_stack")

func play_cosmo_meteor():
	state_machine.travel("cosmo_meteor_start")
	await get_tree().create_timer(25.0).timeout
	state_machine.travel("cosmo_meteor_end")

func play_auto_attack():
	state_machine.travel("auto_attack")
