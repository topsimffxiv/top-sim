extends CharacterBody3D

@onready var skates = get_node("m0514b0002/n_root/Skeleton3D/m0514b0002 Part 0_1")
@onready var legs = get_node("m0514b0002/n_root/Skeleton3D/m0514b0002 Part 1_2")
@onready var skate_waist = get_node("m0514b0002/n_root/Skeleton3D/m0514b0002 Part 1_1")
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var is_following : bool
var moving : bool
var target : PlayableCharacter
var total_time : float = 0.0

var min_dist : float = 15.0
var move_speed : float = 12.0

func _physics_process(delta: float) -> void:
	if !is_following:
		return
	
	self.look_at(target.global_position, Vector3(0, 1, 0), true)
	self.rotation.y += -PI/2
	
	if moving:
		
		var dir = self.global_position.direction_to(target.global_position).normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		
		
		var _vl: = velocity * transform.basis
		move_and_slide()
	
	if self.get_pos().distance_to(target.get_pos()) - min_dist > 0.1 and !moving:
		if total_time < 0.5:
			total_time += delta
		else:
			total_time = 0
			moving = true
			animation_tree.set("parameters/conditions/following", true)
			animation_tree.set("parameters/conditions/waiting", false)
			
	if moving and self.get_pos().distance_to(target.get_pos()) - min_dist <= 0.1:
		moving = false
		animation_tree.set("parameters/conditions/following", false)
		animation_tree.set("parameters/conditions/waiting", true)







func get_pos() -> Vector2:
	return Vector2(self.global_position.x, self.global_position.z)	

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

func start_follow(_body):
	target = _body
	is_following = true

func stop_follow():
	is_following = false
	
func play_cast_dynamis():
	state_machine.travel("cbbm_sp15")
