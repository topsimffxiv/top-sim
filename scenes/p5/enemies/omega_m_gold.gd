extends Node3D

@onready var shield = get_node("m0513b0002/n_root/Skeleton3D/m0513b0002 Part 0_1")
@onready var shield_arm = get_node("m0513b0002/n_root/Skeleton3D/m0513b0002 Part 1_1")
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func get_pos() -> Vector2 :
	return Vector2(self.global_position.x, self.global_position.z)

func play_start_shield() -> void :
	set_shield(true)
	state_machine.travel("idle_shield")
	
func play_start_sword() -> void :
	set_shield(false)
	state_machine.travel("idle_sword")

func play_start_goop() -> void :
	set_shield(false)
	state_machine.travel("idle_goop")

func play_shield_spawn() -> void :
	state_machine.travel("sword_to_shield")
	await get_tree().create_timer(4.0).timeout
	set_shield(true)
	
func play_showoff() -> void :
	set_shield(false)
	state_machine.travel("cbbm_show_sp01")
	await animation_tree.animation_finished
	await get_tree().process_frame
	set_shield(false)
	
func play_shield_despawn() -> void :
	state_machine.travel("sword_to_shield")
	
func play_optimized_bladedance() :
	state_machine.travel("optimized_bladedance")
	
func play_chariot() -> void :
	set_shield(false)
	state_machine.travel("chariot")
	await animation_tree.animation_finished
	await get_tree().process_frame
	set_shield(false)
	
func play_sword_idle_to_goop_idle() -> void :
	set_shield(false)
	state_machine.travel("idle_to_goop")
	
func play_shield_idle_to_goop_idle() -> void :
	set_shield(true)
	state_machine.travel("idle_to_goop")
	
func play_goop_to_idle_sword() -> void :
	set_shield(false)
	state_machine.travel("idle_sword")
	await animation_tree.animation_finished
	await get_tree().process_frame
	set_shield(false)
	
func play_goop_to_idle_shield() -> void :
	set_shield(true)
	state_machine.travel("idle_shield")
	
func play_passage() -> void :
	state_machine.travel("shield_to_passage")
	
func play_end_passage() -> void :
	state_machine.travel("idle_goop")
	
func play_shield_slam() -> void :
	state_machine.travel("shield_slam")
	
func play_beyond_defense() -> void :
	state_machine.travel("beyond_defense")
	
func play_pile_pitch() -> void :
	state_machine.travel("pile_pitch")
	
func play_idle_to_sag() -> void :
	state_machine.travel("idle_sag")
	
func play_sag_to_idle() -> void :
	state_machine.travel("idle_sword")
	
func set_shield(yes : bool) -> void :
	shield.visible = yes
	shield_arm.visible = !yes

func play_cast_dynamis():
	set_shield(false)
	state_machine.travel("cast_dynamis")
