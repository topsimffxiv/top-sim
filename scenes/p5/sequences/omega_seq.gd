extends Node

var debug = false


const HELLO_NEAR_WORLD = preload("res://scenes/ui/auras/debuff_icons/p5/hello_near_world.tscn")
const HELLO_DISTANT_WORLD = preload("res://scenes/ui/auras/debuff_icons/p5/hello_distant_world.tscn")
const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const THRICE_COME_RUIN = preload("res://scenes/ui/auras/debuff_icons/common/thrice_come_ruin.tscn")
const QUICKENING_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p5/quickening_dynamis.tscn")
const HP_PENALTY = preload("res://scenes/ui/auras/debuff_icons/common/hp_penalty.tscn")
const FIRST_IN_LINE = preload("res://scenes/ui/auras/debuff_icons/common/first_in_line.tscn")
const SECOND_IN_LINE = preload("res://scenes/ui/auras/debuff_icons/common/second_in_line.tscn")

var OMEGA_M_GOLD = preload("res://scenes/p5/enemies/omega_m_gold.tscn")
var OMEGA_F_GOLD = preload("res://scenes/p5/enemies/omega_f_gold.tscn")
var HITBOX_RING = preload("res://scenes/common/enemies/hitbox_ring.tscn")
var BEETLE_OMEGA = preload("res://scenes/p1/enemies/beetle_omega.tscn")
var FINAL_OMEGA = preload("res://scenes/p3/enemies/final_omega.tscn")

const HELLO_WORLD_RADIUS_INITIAL : float = 19.0
const HELLO_WORLD_RADIUS : float = 8.0
const HELLO_WORLD_DELAY : float = 1.20

const SKATE_WIDTH : float = 20.0
const STAFF_WIDTH : float = 24.0
const SHIELD_RADIUS : float = 23.5 # 100% correct
const SWORD_RADIUS : float = 23.5
const BLASTER_RADIUS : float = 35.0


# enemy instances, don't instantiate til needed
var omega_f_gold : CharacterBody3D
var hitboxring : Node3D
var omega_f_1 : CharacterBody3D
var omega_f_2 : CharacterBody3D
var omega_m_1 : Node3D
var omega_m_2 : Node3D
var beetle_omega : Node3D
var final_omega : Node3D

@onready var omega_anim: AnimationPlayer = %OmegaAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var chains_controller: ChainsController = %ChainsController
@onready var fail_list: FailList = %FailList

var ns_safe_first : bool # true if diffuse wave cannon hits east/west first
var left_monitor : bool # true if final does left monitor
var rotation_beetle_world : float # m*PI/2
var rotation_first_pair : float # m * PI/2 , male nw female se
var rotation_second_pair : float # rotation_first_pair +- PI/2
var cleave_spawn_pos : Array # list of spawn positions
var m_idx_1 : int
var m_idx_2 : int
var f_idx_1 : int # indices of cleave_spawn_pos for m and f
var f_idx_2 : int

var sword_staff_1 : Array # if first element true, m is sword
var sword_staff_2 : Array
var monitor

var party : Dictionary
var all_keys : Array = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
var player_key : String


var near_key_1: String
var near_key_2: String
var far_key_1: String
var far_key_2: String
var two_stack_keys: Array
var one_stack_keys: Array

var mark_dict: Dictionary  # dictionary of marked players mapping mark to party key

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle", "donut", "diffuse_cone"])
	lockon_controller.pre_load(["Left_Oversampled_Wave_Cannon", "Right_Oversampled_Wave_Cannon",\
								"Target_1", "Target_2", "Target_3", "Target_4",\
								"Link_1", "Link_2", "Mark_Triangle", "Mark_Plus"])
	chains_controller.pre_load(["blaster_tether"])
	instantiate_party(new_party)
	
	
	omega_f_gold = OMEGA_F_GOLD.instantiate()
	get_tree().current_scene.add_child(omega_f_gold)
	omega_f_gold.visible = true
	omega_f_gold.play_start_staff()
	omega_f_gold.global_rotation = Vector3(0, 0, 0)
	omega_f_gold.scale = 6*Vector3(1, 1, 1)
	
	hitboxring = HITBOX_RING.instantiate()
	omega_f_gold.add_child(hitboxring)
	hitboxring.scale = 1.35/6 * Vector3(1, 1, 1)
	hitboxring.position = Vector3(-.1, 0, 0)
	hitboxring.visible = true
	
	omega_anim.play("omega_anim")

	
func instantiate_party(new_party: Dictionary):
	party = new_party
	mark_dict = {}
	
	randomize()
	ns_safe_first = randf() > 0.5 # true if diffuse wave cannon hits east/west first
	left_monitor = randf() > 0.5 # true if final does left monitor
	rotation_beetle_world = PI/2 * randi_range(0, 3) # m*PI/2
	sword_staff_1 = [randf() > 0.5, randf() > 0.5]
	sword_staff_2 = sword_staff_1.duplicate()

	
	if Global.p5_omega_selected_dodge != 0:
		assign_dodge()
	else:
		# randomly change 1 or 2 elements of sword_staff_2
		var i = randi_range(1, 3)
		if i == 1:
			sword_staff_2[0] = !sword_staff_2[0]
		elif i == 2:
			sword_staff_2[1] = !sword_staff_2[1]
		else:
			sword_staff_2[0] = !sword_staff_2[0]
			sword_staff_2[1] = !sword_staff_2[1]
		
	
	if debug:
		print("WARNING: Running in debug mode!")
		ns_safe_first = true
		left_monitor = true
		rotation_beetle_world = 0
	
	for key in all_keys:
		if party[key].is_player():
			player_key = key
	set_dynamis()


func assign_dodge():
	match Global.p5_omega_selected_dodge:
		1: # In -> In
			if randf() > 0.5:
				sword_staff_1 = [true, false]
				sword_staff_2 = [false, false]
			else:
				sword_staff_1 = [false, false]
				sword_staff_2 = [true, false]
		2: # In -> Mid
			if randf() > 0.5:
				sword_staff_1 = [true, false]
				sword_staff_2 = [false, true]
			else:
				sword_staff_1 = [false, false]
				sword_staff_2 = [false, true]
		3: # In -> Far
			if randf() > 0.5:
				sword_staff_1 = [true, false]
				sword_staff_2 = [true, true]
			else:
				sword_staff_1 = [false, false]
				sword_staff_2 = [true, true]
		4: # Mid -> In
			if randf() > 0.5:
				sword_staff_1 = [false, true]
				sword_staff_2 = [true, false]
			else:
				sword_staff_1 = [false, true]
				sword_staff_2 = [false, false]
		5: # Mid -> Far
			sword_staff_1 = [false, true]
			sword_staff_2 = [true, true]
		6: # Far -> In
			if randf() > 0.5:
				sword_staff_1 = [true, true]
				sword_staff_2 = [true, false]
			else:
				sword_staff_1 = [true, true]
				sword_staff_2 = [false, false]
		7: # Far -> Mid
			sword_staff_1 = [true, true]
			sword_staff_2 = [false, true]

func set_dynamis():
	
	var copy_all_keys = all_keys.duplicate()
	randomize()
	copy_all_keys.shuffle()
	
	two_stack_keys = []
	one_stack_keys = []
	
	if debug:
		party["m2"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["m2"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["t1"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["t1"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["h1"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["h1"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["t2"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["t2"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		two_stack_keys = ["m2", "t1", "h1", "t2"]
		two_stack_keys.shuffle()
		
		party["h2"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["m1"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["r1"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		party["r2"].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
		one_stack_keys = ["h2", "m1", "r1", "r2"]
		one_stack_keys.shuffle()
		return
	
	for i in range(8):
		if i < 4:
			party[copy_all_keys[i]].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
			party[copy_all_keys[i]].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
			two_stack_keys.append(copy_all_keys[i])
		else:
			party[copy_all_keys[i]].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
			one_stack_keys.append(copy_all_keys[i])
			
	print("Two stack keys ")
	
func spawn_debuffs():
	
	var shuffled_keys = all_keys.duplicate()
	
	shuffled_keys.shuffle()
	
	near_key_1 = shuffled_keys[0]
	far_key_1 = shuffled_keys[1]
	near_key_2 = shuffled_keys[2]
	far_key_2 = shuffled_keys[3]
	
	if debug:
		near_key_1 = "m2"
		far_key_1 = "h1"
		near_key_2 = "t1"
		far_key_2 = "r2"
	
	party[near_key_1].add_debuff(FIRST_IN_LINE, 10000.0, false, "First In Line")
	var near1_sig = party[near_key_1].add_debuff(HELLO_NEAR_WORLD, 32.0, false, "Hello, Near World")
	near1_sig.connect(snapshot_near_world)
	party[far_key_1].add_debuff(FIRST_IN_LINE, 10000.0, false, "First In Line")
	var far1_sig = party[far_key_1].add_debuff(HELLO_DISTANT_WORLD, 32.0, false, "Hello, Distant World")
	far1_sig.connect(snapshot_distant_world)
	
	
	
	party[near_key_2].add_debuff(SECOND_IN_LINE, 10000.0, false, "Second In Line")
	var near2_sig = party[near_key_2].add_debuff(HELLO_NEAR_WORLD, 50.0, false, "Hello, Near World")
	near2_sig.connect(snapshot_near_world)
	party[far_key_2].add_debuff(SECOND_IN_LINE, 10000.0, false, "Second In Line")
	var far2_sig = party[far_key_2].add_debuff(HELLO_DISTANT_WORLD, 50.0, false, "Hello, Distant World")
	far2_sig.connect(snapshot_distant_world)
	

func remove_first_in_line():
	for key in party:
		party[key].remove_debuff("First In Line")
		
func remove_second_in_line():
	for key in party:
		party[key].remove_debuff("Second In Line")



func hide_party():
	for key in party:
		if key == player_key:
			continue
		party[key].visible = false
		
func show_party():
	for key in party:
		if key == player_key:
			continue
		party[key].visible = true



func show_first_pair():
	omega_f_1 = OMEGA_F_GOLD.instantiate()
	omega_m_1 = OMEGA_M_GOLD.instantiate()
	
	get_tree().current_scene.add_child(omega_m_1)
	get_tree().current_scene.add_child(omega_f_1)
	
	omega_f_1.visible = false
	omega_m_1.visible = false
	
	omega_f_1.scale = 6*Vector3(1, 1, 1)
	omega_m_1.scale = 6*Vector3(1, 1, 1)
	
	cleave_spawn_pos = OPos.CLEAVE_SPAWN_POS
	m_idx_1 = randi_range(0, 3)
	f_idx_1 = (m_idx_1 + 2) % 4
	
	omega_m_1.global_position = cleave_spawn_pos[m_idx_1]
	omega_f_1.global_position = cleave_spawn_pos[f_idx_1]
	
	omega_m_1.global_rotation = Vector3(0, -PI/4 - m_idx_1*PI/2, 0)
	omega_f_1.global_rotation = Vector3(0, -3*PI/4 - f_idx_1*PI/2, 0)
	
	if sword_staff_1[0]:
		omega_m_1.play_start_sword()
	else:
		omega_m_1.play_start_shield()
		
	if sword_staff_1[1]:
		omega_f_1.play_start_staff()
	else:
		omega_f_1.play_start_skates()
		
	omega_m_1.visible = true
	omega_f_1.visible = true

func show_second_pair():
	omega_f_2 = OMEGA_F_GOLD.instantiate()
	omega_m_2 = OMEGA_M_GOLD.instantiate()
	
	get_tree().current_scene.add_child(omega_m_2)
	get_tree().current_scene.add_child(omega_f_2)
	
	omega_f_2.visible = false
	omega_m_2.visible = false
	
	omega_f_2.scale = 6*Vector3(1, 1, 1)
	omega_m_2.scale = 6*Vector3(1, 1, 1)
	
	cleave_spawn_pos = OPos.CLEAVE_SPAWN_POS
	m_idx_2 = ( m_idx_1 + int(2*randi_range(0, 1) + 1) ) % 4
	f_idx_2 = (m_idx_2 + 2) % 4
	
	omega_m_2.global_position = cleave_spawn_pos[m_idx_2]
	omega_f_2.global_position = cleave_spawn_pos[f_idx_2]
	
	omega_m_2.global_rotation = Vector3(0, -PI/4 - m_idx_2*PI/2, 0)
	omega_f_2.global_rotation = Vector3(0, -3*PI/4 - f_idx_2*PI/2, 0)
	
	if sword_staff_2[0]:
		omega_m_2.play_start_sword()
	else:
		omega_m_2.play_start_shield()
		
	if sword_staff_2[1]:
		omega_f_2.play_start_staff()
	else:
		omega_f_2.play_start_skates()
		
	omega_m_2.visible = true
	omega_f_2.visible = true

func snapshot_first_pair():

	var pos_y = 24 + SKATE_WIDTH/4
	var width = 48-SKATE_WIDTH/2
	var length = 110
	
	if sword_staff_1[0]:
		ground_aoe_controller.spawn_circle(omega_m_1.get_pos(), SWORD_RADIUS, 0.3, Color.GOLDENROD, [0, 8, "Efficient Bladework", [], [party[player_key]]], true)
	else:
		ground_aoe_controller.spawn_donut(omega_m_1.get_pos(), SHIELD_RADIUS, 80.0, 0.3, Color.GOLDENROD, [0, 8, "Beyond Strength", [], [party[player_key]]], true)
		
	if sword_staff_1[1]:
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(-PI/4 + f_idx_1*PI/2), STAFF_WIDTH, 110, \
				Vector2(0,0), 0.3, Color.GOLDENROD, [0, 8, "Optimized Blizzard III", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_line(Vector2(23.5, 55).rotated(-PI/4 + f_idx_1*PI/2), STAFF_WIDTH, 110, \
				Vector2(23.5, 0.0).rotated(-PI/4 + f_idx_1*PI/2), 0.3, Color.GOLDENROD, [0, 8, "Optimized Blizzard III", [], [party[player_key]]], true)
	else:
		ground_aoe_controller.spawn_line(Vector2(55, pos_y).rotated(-PI/4 + f_idx_1*PI/2), width, length, \
			Vector2(38, pos_y).rotated(-PI/4 + f_idx_1*PI/2), 0.3, Color.GOLDENROD, [0, 8, "Superliminal Steel", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_line(Vector2(55, -pos_y).rotated(-PI/4 + f_idx_1*PI/2), width, length, \
			Vector2(38, -pos_y).rotated(-PI/4 + f_idx_1*PI/2), 0.3, Color.GOLDENROD, [0, 8, "Superliminal Steel", [], [party[player_key]]], true)
	
	await get_tree().create_timer(1.0).timeout
	
	if sword_staff_1[0]:
		ground_aoe_controller.spawn_circle(omega_m_1.get_pos(), SWORD_RADIUS, 1.0, Color.IVORY, [0, 8, "Efficient Bladework"])
	else:
		ground_aoe_controller.spawn_donut(omega_m_1.get_pos(), SHIELD_RADIUS, 80.0, 1.0, Color.CHOCOLATE, [0, 8, "Beyond Strength"])
		
	if sword_staff_1[1]:
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(-PI/4 + f_idx_1*PI/2), STAFF_WIDTH, 110, \
				Vector2(0,0), 1.0, Color.AQUA, [0, 8, "Optimized Blizzard III"])
		ground_aoe_controller.spawn_line(Vector2(23.5, 55).rotated(-PI/4 + f_idx_1*PI/2), STAFF_WIDTH, 110, \
				Vector2(23.5, 0.0).rotated(-PI/4 + f_idx_1*PI/2), 1.0, Color.AQUA, [0, 8, "Optimized Blizzard III"])
	else:
		ground_aoe_controller.spawn_line(Vector2(55, pos_y).rotated(-PI/4 + f_idx_1*PI/2), width, length, \
			Vector2(38, pos_y).rotated(-PI/4 + f_idx_1*PI/2), 1.0, Color.IVORY, [0, 8, "Superliminal Steel"])
		ground_aoe_controller.spawn_line(Vector2(55, -pos_y).rotated(-PI/4 + f_idx_1*PI/2), width, length, \
			Vector2(38, -pos_y).rotated(-PI/4 + f_idx_1*PI/2), 1.0, Color.IVORY, [0, 8, "Superliminal Steel"])

func snapshot_second_pair():
	var pos_y = 24 + SKATE_WIDTH/4
	var width = 48-SKATE_WIDTH/2
	var length = 110
	
	if sword_staff_2[0]:
		ground_aoe_controller.spawn_circle(omega_m_2.get_pos(), SWORD_RADIUS, 0.3, Color.GOLDENROD, [0, 8, "Efficient Bladework", [], [party[player_key]]], true)
	else:
		ground_aoe_controller.spawn_donut(omega_m_2.get_pos(), SHIELD_RADIUS, 80.0, 0.3, Color.GOLDENROD, [0, 8, "Beyond Strength", [], [party[player_key]]], true)
		
	if sword_staff_2[1]:
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(-PI/4 + f_idx_2*PI/2), STAFF_WIDTH, 110, \
				Vector2(0,0), 0.3, Color.GOLDENROD, [0, 8, "Optimized Blizzard III", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_line(Vector2(23.5, 55).rotated(-PI/4 + f_idx_2*PI/2), STAFF_WIDTH, 110, \
				Vector2(23.5, 0.0).rotated(-PI/4 + f_idx_2*PI/2), 0.3, Color.GOLDENROD, [0, 8, "Optimized Blizzard III", [], [party[player_key]]], true)
	else:
		ground_aoe_controller.spawn_line(Vector2(55, pos_y).rotated(-PI/4 + f_idx_2*PI/2), width, length, \
			Vector2(38, pos_y).rotated(-PI/4 + f_idx_2*PI/2), 0.3, Color.GOLDENROD, [0, 8, "Superliminal Steel", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_line(Vector2(55, -pos_y).rotated(-PI/4 + f_idx_2*PI/2), width, length, \
			Vector2(38, -pos_y).rotated(-PI/4 + f_idx_2*PI/2), 0.3, Color.GOLDENROD, [0, 8, "Superliminal Steel", [], [party[player_key]]], true)
	
	await get_tree().create_timer(1.0).timeout
	
	if sword_staff_2[0]:
		ground_aoe_controller.spawn_circle(omega_m_2.get_pos(), SWORD_RADIUS, 1.0, Color.IVORY, [0, 8, "Efficient Bladework"])
	else:
		ground_aoe_controller.spawn_donut(omega_m_2.get_pos(), SHIELD_RADIUS, 80.0, 1.0, Color.CHOCOLATE, [0, 8, "Beyond Strength"])
		
	if sword_staff_2[1]:
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(-PI/4 + f_idx_2*PI/2), STAFF_WIDTH, 110, \
				Vector2(0,0), 1.0, Color.AQUA, [0, 8, "Optimized Blizzard III"])
		ground_aoe_controller.spawn_line(Vector2(23.5, 55).rotated(-PI/4 + f_idx_2*PI/2), STAFF_WIDTH, 110, \
				Vector2(23.5, 0.0).rotated(-PI/4 + f_idx_2*PI/2), 1.0, Color.AQUA, [0, 8, "Optimized Blizzard III"])
	else:
		ground_aoe_controller.spawn_line(Vector2(55, pos_y).rotated(-PI/4 + f_idx_2*PI/2), width, length, \
			Vector2(38, pos_y).rotated(-PI/4 + f_idx_2*PI/2), 1.0, Color.IVORY, [0, 8, "Superliminal Steel"])
		ground_aoe_controller.spawn_line(Vector2(55, -pos_y).rotated(-PI/4 + f_idx_2*PI/2), width, length, \
			Vector2(38, -pos_y).rotated(-PI/4 + f_idx_2*PI/2), 1.0, Color.IVORY, [0, 8, "Superliminal Steel"])

func play_first_pair():
	if sword_staff_1:
		pass
	
func play_second_pair():
	pass



func snapshot_near_world(_owner_key):
	var second_target_key_list = all_keys.duplicate()
	second_target_key_list.erase(_owner_key)
	var second_target_key = get_closest_key(party[_owner_key].get_pos(), second_target_key_list)
	ground_aoe_controller.spawn_circle(party[_owner_key].get_pos(), HELLO_WORLD_RADIUS_INITIAL, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[_owner_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[_owner_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[second_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[second_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[second_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	var third_target_key_list = all_keys.duplicate()
	third_target_key_list.erase(second_target_key)
	var third_target_key = get_closest_key(party[second_target_key].get_pos(), third_target_key_list)
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[third_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[third_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[third_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
func snapshot_distant_world(_owner_key):
	var second_target_key_list = all_keys.duplicate()
	second_target_key_list.erase(_owner_key)
	var second_target_key = get_furthest_key(party[_owner_key].get_pos(), second_target_key_list)
	ground_aoe_controller.spawn_circle(party[_owner_key].get_pos(), HELLO_WORLD_RADIUS_INITIAL, 0.5, Color.GOLDENROD, [1, 1, "Hello, Distant World"], false)
	party[_owner_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[_owner_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[second_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Distant World"], false)
	party[second_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[second_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	var third_target_key_list = all_keys.duplicate()
	third_target_key_list.erase(second_target_key)
	var third_target_key = get_furthest_key(party[second_target_key].get_pos(), third_target_key_list)
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[third_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Distant World"], false)
	party[third_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[third_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")


func get_closest_key(position: Vector2, keys: Array) -> String:
	var dist = 0.0
	var min_dist = 500.0
	var min_dist_key = ""
	for key in keys:
		dist = position.distance_to(party[key].get_pos())
		if dist < min_dist:
			min_dist_key = key
			min_dist = dist
	return min_dist_key

func get_furthest_key(position: Vector2, keys: Array) -> String:
	var dist = 0.0
	var max_dist = -1.0
	var max_dist_key = ""
	for key in keys:
		dist = position.distance_to(party[key].get_pos())
		if dist > max_dist:
			max_dist_key = key
			max_dist = dist
	return max_dist_key




#Omega M and F stuff
func cast_run_dynamis_omega():
	cast_bar.cast("Run ****mi* (Omega Version)", 4.28)
	await get_tree().create_timer(4.28).timeout
	omega_f_gold.play_cast_dynamis()

func start_follow_player():
	omega_f_gold.start_follow(party[player_key])

func stop_follow_player():
	omega_f_gold.stop_follow()

func show_omega_m_1():
	#omega_m_gold.global_position = SPos.OMEGA_M_SPAWN_POS_1.rotated(Vector3.UP, -rotation_protean)
	#omega_m_gold.global_rotation = Vector3(0, -PI/2 - rotation_protean, 0)
	omega_f_gold.visible = true





func show_omega_f_1():
	omega_f_gold.visible = false
	omega_f_gold.play_start_staff()
	omega_f_gold.global_position = Vector3(0, 0, 0)
	#omega_f_gold.global_rotation.y = -PI-rotation_protean
	omega_f_gold.scale = 6*Vector3(1, 1, 1)
	omega_f_gold.visible = true

func hide_omegas():
	omega_f_gold.stop_follow()
	omega_f_gold.visible = false
	omega_f_1.queue_free()
	omega_f_2.queue_free()
	omega_m_1.queue_free()
	omega_m_2.queue_free()



func show_hitbox_ring():
	hitboxring = HITBOX_RING.instantiate()
	get_tree().current_scene.add_child(hitboxring)
	hitboxring.visible = false
	hitboxring.scale = 1.35 * Vector3(1, 1, 1)
	hitboxring.global_position = Vector3(0.414, 0, 0)
	hitboxring.visible = true

# Final Omega stuff
func play_final_omega_spawn():
	final_omega = FINAL_OMEGA.instantiate()
	get_tree().current_scene.add_child(final_omega)
	final_omega.visible = false
	final_omega.global_position = Vector3(0, 0, 0)
	final_omega.global_rotation = Vector3(0, PI/2, 0)
	final_omega.scale = 2.5 * Vector3(1, 1, 1)
	final_omega.visible = true
	
func hide_final_omega():
	final_omega.visible = false
	final_omega.queue_free()

func play_diffuse_waves_1():
	if ns_safe_first:
		final_omega.play_diffuse_side_idle()
		await get_tree().create_timer(7.5).timeout
		final_omega.play_diffuse_side_end()
	else:
		final_omega.play_diffuse_fb_idle()
		await get_tree().create_timer(7.5).timeout
		final_omega.play_diffuse_fb_end()

func play_diffuse_waves_2():
	if !ns_safe_first:
		final_omega.play_diffuse_side_instant()
	else:
		final_omega.play_diffuse_fb_instant()

func snapshot_diffuse_waves_1():
	if ns_safe_first:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, -10.0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, 10.0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
	else:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90.0, 55.0, Vector2(-10.0, 0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(10.0, 0.0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
	
	await get_tree().create_timer(1.0).timeout
	if ns_safe_first:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, -10.0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, 10.0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])
	else:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90.0, 55.0, Vector2(-10.0, 0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(10.0, 0.0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])

func snapshot_diffuse_waves_2():
	if !ns_safe_first:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, -10.0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, 10.0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
	else:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90.0, 55.0, Vector2(-10.0, 0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(10.0, 0.0), 0.3, Color.GOLDENROD, [0, 8, "Diffuse Wave Cannon", [], [party[player_key]]], true)
	
	await get_tree().create_timer(1.0).timeout
	if !ns_safe_first:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, -10.0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(0, 10.0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])
	else:
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90.0, 55.0, Vector2(-10.0, 0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])
		ground_aoe_controller.spawn_diffuse_cone(Vector2(0, 0), 90, 55.0, Vector2(10.0, 0.0), 1.0, Color.LIGHT_SKY_BLUE, [0, 8, "Diffuse Wave Cannon"])

func play_monitor():
	if left_monitor:
		final_omega.play_left_monitor()
	else:
		final_omega.play_right_monitor()

func spawn_monitor():
	await get_tree().create_timer(1.0).timeout
	if left_monitor:
		monitor = lockon_controller.add_marker("Left_Oversampled_Wave_Cannon", final_omega)
		monitor.set_holder(final_omega)
	else:
		monitor = lockon_controller.add_marker("Right_Oversampled_Wave_Cannon", final_omega)
		monitor.set_holder(final_omega)

	monitor.scale = Vector3(1, 1, 1) * 3.5
	monitor.global_position = final_omega.global_position
	monitor.get_node("FrontLine").visible = false
	monitor.get_node("BackLine").visible = false
	
func snapshot_monitor():

	var bodies = monitor.bodies
	if bodies.size() < 2:
		fail_list.add_fail("Not enough targets for Final Omega monitor")
		return
	if bodies.size() > 2:
		fail_list.add_fail("Too many targets for Final Omega monitor")
		while bodies.size() > 2:
			bodies.remove_at(randi_range(0, bodies.size()-1))
	for body in bodies:
		ground_aoe_controller.spawn_circle(body.get_pos(), 16.0, 0.3, Color.AQUA, [1, 1, "Oversampled Wave Cannon"], false, 0.5)
		body.add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")
		body.add_debuff(THRICE_COME_RUIN, 7.0, true, "Thrice Come Ruin")
	monitor.visible = false
	for key in party:
		if party[key].get_debuff_stacks("Thrice Come Ruin") >= 3:
			fail_list.add_fail(str(party[key].to_string(), " got too many doom stacks"))




# Beetle Omega stuff
func play_beetle_spawn():
	beetle_omega = BEETLE_OMEGA.instantiate()
	get_tree().current_scene.add_child(beetle_omega)
	beetle_omega.visible = false
	beetle_omega.global_position = Vector3(47.0, 0, 0).rotated(Vector3.UP, -rotation_beetle_world)
	beetle_omega.global_rotation.y = -PI/2 - rotation_beetle_world
	beetle_omega.play_arrive()

func play_beetle_leave():
	beetle_omega.play_leave()
	await get_tree().create_timer(1.5).timeout
	beetle_omega.queue_free()

func spawn_blaster_tethers():
	var shuffled_keys = all_keys.duplicate()
	shuffled_keys.shuffle()
	var tether
	if mark_dict["bind1"] == player_key:
		tether = chains_controller.spawn_blaster_tether(beetle_omega, party[shuffled_keys[0]], true)
	else:
		tether = chains_controller.spawn_blaster_tether(beetle_omega, party[mark_dict["bind1"]], false)
		shuffled_keys.erase(party[mark_dict["bind1"]])
	tether.body_intercepted.connect(_pass_tether)
	
	
	var tether2
	if mark_dict["bind2"] == player_key:
		tether2 = chains_controller.spawn_blaster_tether(beetle_omega, party[shuffled_keys[1]], true)
	else:
		tether2 = chains_controller.spawn_blaster_tether(beetle_omega, party[mark_dict["bind2"]], false)
	tether2.body_intercepted.connect(_pass_tether)

func snapshot_blaster_tethers():
	for chain in chains_controller.active_chains:
		var pos = chain.target.get_pos()
		ground_aoe_controller.spawn_circle(pos, BLASTER_RADIUS, 1.2, Color.INDIGO, [1, 1, "Blaster"], false)

func remove_blaster_tethers():
	for chain in chains_controller.active_chains:
		chain.queue_free()

func _pass_tether(tether, body):
	if !tether.allow_pass:
		print("denying pass - tether cannot be passed")
		return
	print("maybe passing tether from %s to %s" % [tether.target.name, body.name])
	var all_chains = chains_controller.active_chains
	var can_pass = true
	for chain in all_chains:
		if chain.target == body:
			can_pass = false
	if can_pass:
		print("successfully passing tether from %s to %s" % [tether.target.name, body.name])
		tether.set_target(body)


# party movement stuff

func move_monitors():
	var pos: Dictionary
	if left_monitor:
		pos = OPos.LEFT_MONITOR_POS
	else:
		pos = OPos.RIGHT_MONITOR_POS
	for key in mark_dict:
		party[mark_dict[key]].move_to(pos[key])
			
func move_blasters():
	var pos = OPos.BLASTER_POS
	for key in mark_dict:
		if key == "bind1":
			party[mark_dict[key]].set_sprint()
			party[mark_dict[key]].move_to(pos["bind1_adjust"].rotated(rotation_beetle_world))
		elif key == "bind2":
			party[mark_dict[key]].set_sprint()
			party[mark_dict[key]].move_to(pos["bind2_adjust"].rotated(rotation_beetle_world))
		else:
			party[mark_dict[key]].move_to(pos[key].rotated(rotation_beetle_world))
	await get_tree().create_timer(4.0).timeout
	party[mark_dict["bind1"]].move_to(pos["bind1"].rotated(rotation_beetle_world))
	party[mark_dict["bind2"]].move_to(pos["bind2"].rotated(rotation_beetle_world))
	
func adjust_blasters():
	var pos = OPos.ADJUST_BLASTER_POS
	for key in pos:
		party[mark_dict[key]].move_to(pos[key].rotated(rotation_beetle_world))



func mark_players_1():
	if Global.p5_disable_markers:
		return
	
	mark_dict["near"] = near_key_1
	mark_dict["far"] = far_key_1
	
	# find binds
	var binds = []
	var binds_left = 2
	
	var two_stack_copy = two_stack_keys.duplicate()
	for key in two_stack_keys:
		print("looping ... key is %s" % key)
		if key == near_key_1:
			print("in here, %s" % near_key_1)
			two_stack_copy.erase(key)
		if key == far_key_1:
			two_stack_copy.erase(key)
	
	if two_stack_copy.has(near_key_2):
		binds.append(near_key_2)
		two_stack_copy.erase(near_key_2)
		binds_left -= 1
	if two_stack_copy.has(far_key_2):
		binds.append(far_key_2)
		two_stack_copy.erase(far_key_2)
		binds_left -= 1
		
	while binds_left > 0:
		binds.append(two_stack_copy[0])
		binds_left -= 1
		two_stack_copy.remove_at(0)
		
	mark_dict["bind1"] = binds[0]
	mark_dict["bind2"] = binds[1]

		
	
	var copy_all_keys = all_keys.duplicate()
	copy_all_keys.erase(mark_dict["bind1"])
	copy_all_keys.erase(mark_dict["bind2"])
	copy_all_keys.erase(mark_dict["near"])
	copy_all_keys.erase(mark_dict["far"])
	copy_all_keys.shuffle()
	
	mark_dict["target1"] = copy_all_keys[0]
	mark_dict["target2"] = copy_all_keys[1]
	mark_dict["target3"] = copy_all_keys[2]
	mark_dict["target4"] = copy_all_keys[3]
		
	lockon_controller.add_marker("Mark_Triangle", party[mark_dict["near"]])
	lockon_controller.add_marker("Mark_Plus", party[mark_dict["far"]])
	lockon_controller.add_marker("Link_1", party[mark_dict["bind1"]])
	lockon_controller.add_marker("Link_2", party[mark_dict["bind2"]])
	lockon_controller.add_marker("Target_1", party[mark_dict["target1"]])
	lockon_controller.add_marker("Target_2", party[mark_dict["target2"]])
	lockon_controller.add_marker("Target_3", party[mark_dict["target3"]])
	lockon_controller.add_marker("Target_4", party[mark_dict["target4"]])
	
	print(mark_dict)
	
func mark_players_2():
	
	mark_dict["near"] = near_key_2
	mark_dict["far"] = far_key_2
	
	var two_stack_copy = two_stack_keys.duplicate()
	two_stack_copy.erase(mark_dict["bind1"])
	two_stack_copy.erase(mark_dict["bind2"])
	two_stack_copy.shuffle()
	mark_dict["bind1"] = two_stack_copy[0]
	mark_dict["bind2"] = two_stack_copy[1]
	
	var copy_all_keys = all_keys.duplicate()
	copy_all_keys.erase(mark_dict["bind1"])
	copy_all_keys.erase(mark_dict["bind2"])
	copy_all_keys.erase(mark_dict["near"])
	copy_all_keys.erase(mark_dict["far"])
	copy_all_keys.shuffle()
	
	mark_dict["target1"] = copy_all_keys[0]
	mark_dict["target2"] = copy_all_keys[1]
	mark_dict["target3"] = copy_all_keys[2]
	mark_dict["target4"] = copy_all_keys[3]
	
	lockon_controller.add_marker("Mark_Triangle", party[mark_dict["near"]])
	lockon_controller.add_marker("Mark_Plus", party[mark_dict["far"]])
	lockon_controller.add_marker("Link_1", party[mark_dict["bind1"]])
	lockon_controller.add_marker("Link_2", party[mark_dict["bind2"]])
	lockon_controller.add_marker("Target_1", party[mark_dict["target1"]])
	lockon_controller.add_marker("Target_2", party[mark_dict["target2"]])
	lockon_controller.add_marker("Target_3", party[mark_dict["target3"]])
	lockon_controller.add_marker("Target_4", party[mark_dict["target4"]])
	

func unmark_players():
	if Global.p5_disable_markers:
		return
	lockon_controller.remove_marker("Mark_Triangle", party[mark_dict["near"]])
	lockon_controller.remove_marker("Mark_Plus", party[mark_dict["far"]])
	lockon_controller.remove_marker("Link_1", party[mark_dict["bind1"]])
	lockon_controller.remove_marker("Link_2", party[mark_dict["bind2"]])
	lockon_controller.remove_marker("Target_1", party[mark_dict["target1"]])
	lockon_controller.remove_marker("Target_2", party[mark_dict["target2"]])
	lockon_controller.remove_marker("Target_3", party[mark_dict["target3"]])
	lockon_controller.remove_marker("Target_4", party[mark_dict["target4"]])
