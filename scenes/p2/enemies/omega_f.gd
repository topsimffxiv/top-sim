extends Node3D

@onready var skates = get_node("m0514b0001/n_root/Skeleton3D/m0514b0001 Part 0_1")
@onready var legs = get_node("m0514b0001/n_root/Skeleton3D/m0514b0001 Part 1_2")
@onready var skate_waist = get_node("m0514b0001/n_root/Skeleton3D/m0514b0001 Part 1_1")
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func set_staff(yes : bool) -> void :
	legs.visible = yes
	skates.visible = !yes
	skate_waist.visible = !yes

func play_start_staff() -> void :
	set_staff(true)
	state_machine.travel("idle_staff")
	
func play_start_skates() -> void :
	set_staff(false)
	state_machine.travel("idle_skates")

func play_start_goop() -> void :
	set_staff(true)
	state_machine.travel("idle_goop")
	
func play_steel() -> void :
	state_machine.travel("steel")
	
func play_skate_to_staff() -> void : 
	set_staff(true)
	state_machine.travel("skate_to_staff")
	
func play_idle_to_goop() -> void :
	set_staff(true)
	state_machine.travel("idle_to_goop")

func play_goop_to_idle() -> void :
	set_staff(true)
	state_machine.travel("goop_to_idle")
	
func play_staff_to_skate() -> void :
	set_staff(false)
	state_machine.travel("staff_to_skate")
	
func play_optimized_bladedance() -> void :
	state_machine.travel("optimized_bladedance")
	
func play_showoff() -> void :
	state_machine.travel("cbbm_show_sp01")
	
func play_blizzard() -> void :
	state_machine.travel("blizzard")
	
func play_staff_to_meteor() -> void :
	state_machine.travel("staff_to_meteor")
	
func play_meteor_to_staff() -> void :
	state_machine.travel("meteor_to_staff")
	
func play_staff_to_laser_shower() -> void :
	state_machine.travel("idle_to_laser_shower")
	
func play_laser_shower_to_staff() -> void :
	state_machine.travel("idle_staff")
