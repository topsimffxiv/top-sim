extends Node

var debug = false


const HELLO_NEAR_WORLD = preload("res://scenes/ui/auras/debuff_icons/p5/hello_near_world.tscn")
const HELLO_DISTANT_WORLD = preload("res://scenes/ui/auras/debuff_icons/p5/hello_distant_world.tscn")
const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const THRICE_COME_RUIN = preload("res://scenes/ui/auras/debuff_icons/common/thrice_come_ruin.tscn")
const QUICKENING_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p5/quickening_dynamis.tscn")
const REMOTE_GLITCH = preload("res://scenes/ui/auras/debuff_icons/common/remote_glitch.tscn")
const MID_GLITCH = preload("res://scenes/ui/auras/debuff_icons/common/mid_glitch.tscn")
const LOOPER = preload("res://scenes/ui/auras/debuff_icons/common/looper.tscn")

var OMEGA_M_GOLD = preload("res://scenes/p5/enemies/omega_m_gold.tscn")
var OMEGA_F_GOLD = preload("res://scenes/p5/enemies/omega_f_gold.tscn")
var PUDDLE = preload("res://scenes/p2/enemies/omega_puddle.tscn")
var HITBOX_RING = preload("res://scenes/common/enemies/hitbox_ring.tscn")
var BEETLE_OMEGA = preload("res://scenes/p1/enemies/beetle_omega.tscn")
var FINAL_OMEGA = preload("res://scenes/p3/enemies/final_omega.tscn")
var OMEGA_HALO = preload("res://scenes/p5/enemies/omega_halo.tscn")
var SPINNY_ANTI = preload("res://scenes/p5/enemies/anticlockwise_spinny.tscn")
var SPINNY = preload("res://scenes/p5/enemies/clockwise_spinny.tscn")
var LEFT_ARM = preload("res://scenes/p3/enemies/left_arm_unit.tscn")
var RIGHT_ARM = preload("res://scenes/p3/enemies/right_arm_unit.tscn")

const HELLO_WORLD_RADIUS_INITIAL : float = 19.0
const HELLO_WORLD_RADIUS : float = 8.0
const HELLO_WORLD_DELAY : float = 1.20

const SKATE_WIDTH : float = 20.0
const STAFF_WIDTH : float = 24.0
const SHIELD_RADIUS : float = 25.0
const SWORD_RADIUS : float = 24.0

const CHAIN_MIN_LENGTH_MID : float = 45.0
const CHAIN_MAX_LENGTH_MID : float = 65.0
const CHAIN_MIN_LENGTH_REMOTE : float = 85.0
const CHAIN_MAX_LENGTH_REMOTE : float = 95.0


# enemy instances, don't instantiate til needed
var omega_m_gold : Node3D
var omega_f_gold : Node3D
var puddle : Node3D
var beetle_omega : Node3D
var omega_halo : Node3D
var final_omega : Node3D

var left_arm : Node3D
var right_arm: Node3D

@onready var sigma_anim: AnimationPlayer = %SigmaAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var chains_controller: ChainsController = %ChainsController
@onready var fail_list: FailList = %FailList

var rotation_protean : float # scalar rotation value, n*PI/4
var rotation_tower : float # 0 or PI
var rotation_hello_world : float # m*PI/4
var remote : bool
var clockwise : bool # if true, halo spins clockwise
var wait : bool # true is omega f is staff

var party : Dictionary
var all_keys : Array = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
var player_key : String
var pairs : Array # bpog, left then right
var blue_pair : Array
var purple_pair : Array
var orange_pair : Array
var green_pair : Array

var random = true
var bind1 = false
var bind2 = false
var target1 = false
var target2 = false
var target3 = false
var target4 = false
var near = false
var far = false

var laser_bait_1: String # key intended to bait hand 1
var laser_bait_1_idx: int
var laser_bait_2: String # key intended to bait hand 2
var laser_bait_2_idx: int
var bait_idx: int
var protean_keys: Array
var near_key: String
var far_key: String
var dynamis_starters: Array # list of players w/ one stack of dynamis at start of sigma
var mark_dict: Dictionary # near, far, target1, bind1, etc -> party key

var laser_cluster_1: Dictionary = {}
var laser_cluster_2: Dictionary = {}
var glitches = []
var cluster_1_target_key # current farthest from hand 1
var cluster_2_target_key # current farthest from hand 2
var protean_marker: Dictionary = {} # protean_marker[party_key] = "marker" stood at during proteans
var towers: Array = [] # list of looper towers
var spinner

var frame_counter = 0

func _physics_process(_delta: float) -> void:
	frame_counter += 1
	if frame_counter % 5 == 0 and laser_cluster_1.size()!=0:
		update_laser_targets()

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle", "looper_solo_tower", "looper_pair_tower"])
	lockon_controller.pre_load(["Left_Oversampled_Wave_Cannon", "Right_Oversampled_Wave_Cannon", "Sharp_Target",\
								"PS_Cross", "PS_Square", "PS_Circle", "PS_Triangle",\
								"Target_1", "Target_2", "Target_3", "Target_4",\
								"Link_1", "Link_2", "Mark_Triangle", "Mark_Plus"])
	chains_controller.pre_load(["glitch", "laser_hand_tether"])
	instantiate_party(new_party)
	
	
	left_arm = LEFT_ARM.instantiate()
	right_arm = RIGHT_ARM.instantiate()
	
	get_tree().current_scene.get_node("Enemies").add_child(left_arm)
	get_tree().current_scene.get_node("Enemies").add_child(right_arm)
	left_arm.visible = false
	right_arm.visible = false
	
	omega_m_gold = OMEGA_M_GOLD.instantiate()
	get_tree().current_scene.add_child(omega_m_gold)
	omega_m_gold.visible = true
	omega_m_gold.play_start_sword()
	omega_m_gold.global_rotation = Vector3(0, PI/2, 0)
	omega_m_gold.scale = 6*Vector3(1, 1, 1)
	
	sigma_anim.play("sigma_anim")
	
	

	
func instantiate_party(new_party: Dictionary):
	party = new_party
	assign_role()
	
	randomize()
	rotation_protean = randi_range(0, 7) * PI/4 # scalar rotation value
	rotation_tower = randi_range(0, 1) * PI
	rotation_hello_world = randi_range(0, 7) * PI/4
	laser_bait_1_idx = randi_range(0, 1)
	laser_bait_2_idx = randi_range(0, 1)
	wait = randf() > 0.5
	clockwise = randf() > 0.5
	
	if Global.p5_force_remote:
		remote = true
	elif Global.p5_force_mid:
		remote = false
	else:
		remote = randf() > 0.5
	
	if debug:
		print("WARNING: Running in debug mode!")
		rotation_protean = 0
		rotation_tower = 0
		rotation_hello_world = 0
		wait = false
		clockwise = false
	
	# setup tether pairs
	pairs = all_keys.duplicate()
	for key in pairs:
		if party[key].is_player():
			player_key = key
	set_dynamis()

	pairs.shuffle()	 # BPOG, all left then all right sequentially
	
	blue_pair = pairs.slice(0, 2)
	purple_pair = pairs.slice(2, 4)
	orange_pair = pairs.slice(4, 6)
	green_pair = pairs.slice(6, 8)
	
	# pick two players to not be targeted with proteans
	# players that are baits + partners are known
	var laser_target_keys = [blue_pair[0], purple_pair[0], orange_pair[0], green_pair[0]]
	laser_target_keys.shuffle()
	laser_target_keys = laser_target_keys.slice(0, 2)
	var t1idx = pairs.find(laser_target_keys[0]) + laser_bait_1_idx
	var t2idx = pairs.find(laser_target_keys[1]) + laser_bait_2_idx
	if t1idx < t2idx :
		laser_bait_1 = pairs[t1idx]
		laser_bait_2 = pairs[t2idx]
	else:
		laser_bait_1 = pairs[t2idx]
		laser_bait_2 = pairs[t1idx]
	
func assign_role():
	if Global.p5_sigma_selected_debuff == 0:
		return
	random = false
	if Global.p5_sigma_selected_debuff == 1:
		bind1 = true
	elif Global.p5_sigma_selected_debuff == 2:
		bind2 = true
	elif Global.p5_sigma_selected_debuff == 3:
		target1 = true
	elif Global.p5_sigma_selected_debuff == 4:
		target2 = true
	elif Global.p5_sigma_selected_debuff == 5:
		target3 = true
	elif Global.p5_sigma_selected_debuff == 6:
		target4 = true
	elif Global.p5_sigma_selected_debuff == 7:
		near = true
	elif Global.p5_sigma_selected_debuff == 8:
		far = true
	else:
		print("sigma role selection out of bounds")

func set_dynamis():
	
	var copy_all_keys = all_keys.duplicate()
	randomize()
	copy_all_keys.shuffle()
	
	if target1 or bind1 or bind2:
		dynamis_starters.append(player_key)
		copy_all_keys.erase(player_key)
		for i in range(5):
			dynamis_starters.append(copy_all_keys[i])
	else:
		for i in range(6):
			dynamis_starters.append(copy_all_keys[i])
			
	for key in dynamis_starters:
		party[key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")



func spawn_arms_1():
	
	left_arm.global_position = SPos.LEFT_ARM_SPAWN_POS_1.rotated(Vector3.UP, -rotation_protean)
	left_arm.rotation = Vector3(0, PI/4 - rotation_protean, 0)
	
	right_arm.global_position = SPos.RIGHT_ARM_SPAWN_POS_1.rotated(Vector3.UP, -rotation_protean)
	right_arm.rotation = Vector3(0, 3*PI/4 - rotation_protean, 0)
	
	show_arms()
	
func spawn_arms_2():
	left_arm.global_position = Vector3(-33.5, 0, -33.5).rotated(Vector3.UP, -rotation_hello_world)
	left_arm.rotation = Vector3(0, PI/4 - rotation_hello_world, 0)
	right_arm.global_position = Vector3(-33.5, 0, 33.5).rotated(Vector3.UP, -rotation_hello_world)
	right_arm.rotation = Vector3(0, 3*PI/4 - rotation_hello_world, 0)
	
	show_arms()

func spawn_laser_clusters():	
	for key in all_keys:
		laser_cluster_1[key] = (chains_controller.spawn_laser_hand_tether(left_arm, party[key]))
		laser_cluster_2[key] = (chains_controller.spawn_laser_hand_tether(right_arm, party[key]))

func update_laser_targets():
	
	var target_1_key = get_furthest_key(Vector2(left_arm.global_position.x, left_arm.global_position.z), all_keys)
	var target_2_key = get_furthest_key(Vector2(right_arm.global_position.x, right_arm.global_position.z), all_keys)
	
	if !cluster_1_target_key or !cluster_2_target_key:
		cluster_1_target_key = target_1_key
		laser_cluster_1[cluster_1_target_key].visible = true
		cluster_2_target_key = target_2_key
		laser_cluster_2[cluster_2_target_key].visible = true
	
	if cluster_1_target_key != target_1_key:
		laser_cluster_1[cluster_1_target_key].visible = false
		laser_cluster_1[target_1_key].visible = true
		cluster_1_target_key = target_1_key
	if cluster_2_target_key != target_2_key:
		laser_cluster_2[cluster_2_target_key].visible = false
		laser_cluster_2[target_2_key].visible = true
		cluster_2_target_key = target_2_key
	
func hide_arms():
	left_arm.visible = false
	right_arm.visible = false
	
func show_arms():
	left_arm.visible = true
	right_arm.visible = true





func spawn_debuffs():
	
	var copy_all_keys = all_keys.duplicate()
	if !random: 
		copy_all_keys.erase(player_key)
	if near:
		near_key = player_key
		far_key = copy_all_keys[randi_range(0, 6)]
	elif far:
		far_key = player_key
		near_key = copy_all_keys[randi_range(0, 6)]
	else:
		if !random:
			near_key = copy_all_keys[randi_range(0, 6)]
			copy_all_keys.erase(near_key)
			far_key = copy_all_keys[randi_range(0, 5)]
		else:
			near_key = copy_all_keys[randi_range(0, 7)]
			copy_all_keys.erase(near_key)
			far_key = copy_all_keys[randi_range(0, 6)]
		
	var near_world = party[near_key].add_debuff(HELLO_NEAR_WORLD, 56.0, false, "Hello, Near World")
	near_world.connect(snapshot_near_world)
	var far_world = party[far_key].add_debuff(HELLO_DISTANT_WORLD, 56.0, false, "Hello, Distant World")
	far_world.connect(snapshot_distant_world)
	
	var icons = ["PS_Cross", "PS_Square", "PS_Circle", "PS_Triangle"]
	var maxlen
	var minlen
	if remote :
		maxlen = CHAIN_MAX_LENGTH_REMOTE
		minlen = CHAIN_MIN_LENGTH_REMOTE
	else :
		maxlen = CHAIN_MAX_LENGTH_MID
		minlen = CHAIN_MIN_LENGTH_MID
	for i in range(0, 4) :
		var source = party[pairs[2*i]]
		var target = party[pairs[2*i+1]]
		if remote:
			var debuff = source.add_debuff(REMOTE_GLITCH, 32.0, false, "Remote Glitch")
			target.add_debuff(REMOTE_GLITCH, 32.0, false, "Remote Glitch")
			debuff.connect(_on_glitch_timeout)
		else:
			var debuff = source.add_debuff(MID_GLITCH, 32.0, false, "Mid Glitch")
			target.add_debuff(MID_GLITCH, 32.0, false, "Mid Glitch")
			debuff.connect(_on_glitch_timeout)
		glitches.append(chains_controller.spawn_glitch(source, target, maxlen, minlen))
		lockon_controller.add_marker(icons[i], source)
		lockon_controller.add_marker(icons[i], target)

func _on_glitch_timeout(owner_key) -> void :
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("Chain")
	if !chain:
		return
	chain.erase_vuln()
	chains_controller.remove_chain(chain)

func hide_playstation_markers():
	var icons = ["PS_Cross", "PS_Square", "PS_Circle", "PS_Triangle"]
	var all_pairs = blue_pair + purple_pair + orange_pair + green_pair
	for i in range(icons.size()):
		lockon_controller.remove_marker(icons[i], party[all_pairs[2*i]])
		lockon_controller.remove_marker(icons[i], party[all_pairs[2*i+1]])
		
func spawn_sharp_targets():
	protean_keys = all_keys.duplicate()
	protean_keys.erase(laser_bait_1)
	protean_keys.erase(laser_bait_2)
	for key in protean_keys:
		lockon_controller.add_marker("Sharp_Target", party[key])

func hide_sharp_targets():
	for key in protean_keys:
		lockon_controller.remove_marker("Sharp_Target", party[key])

func snapshot_lasers():
	for key in protean_keys:
		if party[key].has_debuff("Vulnerability Up"):
			fail_list.add_fail(str(party[key].get_name(), " did not satisfy distance requirement during wave cannon"))
		ground_aoe_controller.spawn_cone(Vector2(0, 0), 100.0, 50.0, party[key].get_pos(), 1.0, Color.AQUA, [1, 1, "Wave Cannon"])
		party[key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")
	ground_aoe_controller.spawn_line(left_arm.get_pos(), 9.0, 95.0, party[cluster_1_target_key].get_pos(), 1.0, Color.AQUA, [1, 1, "Hyper Laser"], false)
	ground_aoe_controller.spawn_line(right_arm.get_pos(), 9.0, 95.0, party[cluster_2_target_key].get_pos(), 1.0, Color.AQUA, [1, 1, "Hyper Laser"], false)
	party[cluster_1_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")
	party[cluster_2_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")

func snapshot_lasers_2():
	ground_aoe_controller.spawn_line(left_arm.get_pos(), 9.0, 95.0, party[cluster_1_target_key].get_pos(), 1.0, Color.AQUA, [1, 1, "Hyper Laser"], false)
	ground_aoe_controller.spawn_line(right_arm.get_pos(), 9.0, 95.0, party[cluster_2_target_key].get_pos(), 1.0, Color.AQUA, [1, 1, "Hyper Laser"], false)
	party[cluster_1_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")
	party[cluster_2_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")


func spawn_looper_debuffs():
	for key in all_keys:
		party[key].add_debuff(LOOPER, 18.0, false, "Looper")
	
func spawn_looper_towers():
	var pos: Dictionary
	if remote:
		pos = SPos.REMOTE_GLITCH_TOWER_SPAWN_POS
		towers.append(ground_aoe_controller.spawn_looper_pair_tower(pos["12"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_pair_tower(pos["B3"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_pair_tower(pos["C4"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_solo_tower(pos["A"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_solo_tower(pos["D"].rotated(rotation_protean + rotation_tower), 9.5))
	else:
		pos = SPos.MID_GLITCH_TOWER_SPAWN_POS
		towers.append(ground_aoe_controller.spawn_looper_pair_tower(pos["A3"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_pair_tower(pos["D4"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_solo_tower(pos["1"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_solo_tower(pos["2"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_solo_tower(pos["B"].rotated(rotation_protean + rotation_tower), 9.5))
		towers.append(ground_aoe_controller.spawn_looper_solo_tower(pos["C"].rotated(rotation_protean + rotation_tower), 9.5))

func snapshot_looper_towers():
	for tower in towers:
		if tower.soaked == LooperSoloTower.SoakState.UNDER:
			fail_list.add_fail("Not enough bodies to soak tower")
		elif tower.soaked == LooperSoloTower.SoakState.OVER:
			fail_list.add_fail("Too many bodies soaking tower")
		else:
			for body in tower.bodies_array:
				body.remove_debuff("Looper")
				if body.has_debuff("Vulnerability Up"):
					fail_list.add_fail("%s did not satisfy distance requirement during tower soak" % body.name)
				body.add_debuff(THRICE_COME_RUIN, 11.0, false, "Twice-come Ruin")
	
func hide_looper_towers():
	for tower in towers:
		tower.visible = false
		tower.queue_free()



func snapshot_omega_f_cleave():
	if !wait:
		var pos_y = 24 + SKATE_WIDTH/4
		var width = 48-SKATE_WIDTH/2
		var length = 110
		
		ground_aoe_controller.spawn_line(Vector2(55, pos_y).rotated(rotation_hello_world), width, length, \
				Vector2(38, pos_y).rotated(rotation_hello_world), 0.3, Color.GOLDENROD, [0, 0, "Superliminal Steel"], true)
		ground_aoe_controller.spawn_line(Vector2(55, -pos_y).rotated(rotation_hello_world), width, length, \
				Vector2(38, -pos_y).rotated(rotation_hello_world), 0.3, Color.GOLDENROD, [0, 0, "Superliminal Steel"], true)
		
		
		await get_tree().create_timer(1.0).timeout
		ground_aoe_controller.spawn_line(Vector2(55, pos_y).rotated(rotation_hello_world), width, length, \
				Vector2(38, pos_y).rotated(rotation_hello_world), 1.0, Color.IVORY, [0, 8, "Superliminal Steel"])
		ground_aoe_controller.spawn_line(Vector2(55, -pos_y).rotated(rotation_hello_world), width, length, \
				Vector2(38, -pos_y).rotated(rotation_hello_world), 1.0, Color.IVORY, [0, 8, "Superliminal Steel"])
	  
	else:
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(rotation_hello_world), STAFF_WIDTH, 110, Vector2(0,0), \
			 0.3, Color.GOLDENROD, [0, 0, "Optimized Blizzard III"], true)
		ground_aoe_controller.spawn_line(Vector2(SPos.OMEGA_F_SPAWN_POS_2.x, 55).rotated(rotation_hello_world), STAFF_WIDTH, 110, \
			Vector2(SPos.OMEGA_F_SPAWN_POS_2.x, SPos.OMEGA_F_SPAWN_POS_2.z).rotated(rotation_hello_world), 0.3, Color.GOLDENROD, [0, 0, "Optimized Blizzard III"], true)
			
		await get_tree().create_timer(1.0).timeout
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(rotation_hello_world), STAFF_WIDTH, 110, Vector2(0,0), \
			 1.0, Color.AQUA, [0, 8, "Optimized Blizzard III"])
		ground_aoe_controller.spawn_line(Vector2(SPos.OMEGA_F_SPAWN_POS_2.x, 55).rotated(rotation_hello_world), STAFF_WIDTH, 110, \
			Vector2(SPos.OMEGA_F_SPAWN_POS_2.x, SPos.OMEGA_F_SPAWN_POS_2.z).rotated(rotation_hello_world), 1.0, Color.AQUA, [0, 8, "Optimized Blizzard III"])



func snapshot_near_world(_owner_key):
	var second_target_key_list = all_keys.duplicate()
	second_target_key_list.erase(near_key)
	var second_target_key = get_closest_key(party[near_key].get_pos(), second_target_key_list)
	ground_aoe_controller.spawn_circle(party[near_key].get_pos(), HELLO_WORLD_RADIUS_INITIAL, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[near_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[near_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
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
	second_target_key_list.erase(far_key)
	var second_target_key = get_furthest_key(party[far_key].get_pos(), second_target_key_list)
	ground_aoe_controller.spawn_circle(party[far_key].get_pos(), HELLO_WORLD_RADIUS_INITIAL, 0.5, Color.GOLDENROD, [1, 1, "Hello, Distant World"], false)
	party[far_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[far_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
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
func cast_run_dynamis_sigma():
	cast_bar.cast("Run ****mi* (Sigma Version)", 4.28)
	await get_tree().create_timer(4.28).timeout
	omega_m_gold.play_cast_dynamis()
	await omega_m_gold.animation_tree.animation_finished
	omega_m_gold.visible = false

func show_omega_m_2():
	omega_m_gold.global_position = SPos.OMEGA_M_SPAWN_POS_1.rotated(Vector3.UP, -rotation_protean)
	omega_m_gold.global_rotation = Vector3(0, -PI/2 - rotation_protean, 0)
	omega_m_gold.visible = true

func goop_omega_m():
	omega_m_gold.play_sword_idle_to_goop_idle()
	await get_tree().create_timer(2.5).timeout

	puddle = PUDDLE.instantiate()
	get_tree().current_scene.add_child(puddle)
	puddle.global_position = omega_m_gold.global_position
	
	var tween_m = create_tween()
	tween_m.tween_property(omega_m_gold, "position", omega_m_gold.global_position + Vector3(0, -20 , 0), 1.5)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	puddle.play_expand()
	await tween_m.finished
	omega_m_gold.queue_free()

func goop_omega_f():

	omega_f_gold = OMEGA_F_GOLD.instantiate()
	get_tree().current_scene.add_child(omega_f_gold)
	omega_f_gold.scale = 6*Vector3(1, 1, 1)
	omega_f_gold.play_start_goop()
	omega_f_gold.global_position = SPos.OMEGA_M_SPAWN_POS_1.rotated(Vector3.UP, -rotation_protean) - Vector3(0, 20, 0)
	omega_f_gold.global_rotation.y = -PI-rotation_protean

	var tween_f = create_tween()
	tween_f.tween_property(omega_f_gold, "position", omega_f_gold.global_position + Vector3(0, 20 , 0), 1.5)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	puddle.play_shrink()
	
	await get_tree().create_timer(4.0).timeout
	omega_f_gold.play_goop_to_idle()

func show_omega_f_1():
	omega_f_gold.visible = false
	omega_f_gold.play_start_staff()
	omega_f_gold.global_position = Vector3(0, 0, 0)
	omega_f_gold.global_rotation.y = -PI-rotation_protean
	omega_f_gold.scale = 6*Vector3(1, 1, 1)
	omega_f_gold.visible = true

func play_knockback():
	omega_f_gold.play_blizzard()

func hide_omega_f():
	omega_f_gold.visible = false

func show_omega_f_2():
	if !wait:
		omega_f_gold.play_start_skates()
	omega_f_gold.global_position = SPos.OMEGA_F_SPAWN_POS_2.rotated(Vector3.UP, -rotation_hello_world)
	omega_f_gold.global_rotation.y = -PI - rotation_hello_world
	
	omega_f_gold.visible = true
	
func play_omega_f_cleave():
	if wait:
		omega_f_gold.play_blizzard()
	else:
		omega_f_gold.play_steel()

func show_omega_f_3():
	omega_f_gold.play_start_staff()
	omega_f_gold.global_position = Vector3(0,0,0)
	omega_f_gold.global_rotation.y = 0
	omega_f_gold.visible = true

func show_hitbox_ring():
	var hitboxring = HITBOX_RING.instantiate()
	get_tree().current_scene.add_child(hitboxring)
	hitboxring.visible = false
	hitboxring.scale = 1.35 * Vector3(1, 1, 1)
	hitboxring.global_position = Vector3(0.414, 0, 0)
	hitboxring.visible = true


func snapshot_knockback():
	for key in party :
		var pc = party[key]
		pc.knockback(30, Vector2(0, 0))

# Final Omega stuff
func play_final_omega_spawn():
	final_omega = FINAL_OMEGA.instantiate()
	get_tree().current_scene.add_child(final_omega)
	final_omega.visible = false
	final_omega.global_position = Vector3(0, 0, 0)
	final_omega.global_rotation = Vector3(0, -PI/2 - rotation_protean, 0)
	final_omega.scale = 2.5 * Vector3(1, 1, 1)
	final_omega.visible = true

func play_wave_cannon():
	final_omega.play_wave_cannon_p5()

func play_hand_lasers():
	left_arm.play_laser_blast()
	right_arm.play_laser_blast()
	await get_tree().create_timer(1.9).timeout
	left_arm.play_idle()
	right_arm.play_idle()
	
func hide_final_omega():
	final_omega.visible = false



	
# Omega Halo stuff	
func spawn_halo():
	omega_halo = OMEGA_HALO.instantiate()
	get_tree().current_scene.add_child(omega_halo)
	omega_halo.global_rotation.y = omega_halo.global_rotation.y - rotation_hello_world

func spawn_spinny():
	if clockwise:
		spinner = SPINNY.instantiate()
	else:
		spinner = SPINNY_ANTI.instantiate()
	get_tree().current_scene.add_child(spinner)

func hide_spinny():
	spinner.visible = false
	spinner.queue_free()
	
func spawn_halo_line_pre():
	ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(rotation_hello_world), 29, 110, Vector2(-55, 0).rotated(rotation_hello_world), 2.6, Color.GOLDENROD, [0, 0, "Rear Lasers"], true)

func snapshot_halo_rotating_line():
	var num_shots = 14
	var total_time = 7.4 # seconds from start of first shot to start of last shot
	var shot_rotation = deg_to_rad(9.038) # number of degrees between each shot (1.5 tick marks)
	if !clockwise:
		shot_rotation = -deg_to_rad(9.038)
	
	for i in range(num_shots):
		omega_halo.play_laser_blast()
		omega_halo.global_rotation.y = omega_halo.global_rotation.y - shot_rotation
		ground_aoe_controller.spawn_line(Vector2(55, 0).rotated(rotation_hello_world + i*shot_rotation), 29, 110, \
			Vector2(-55,0).rotated(rotation_hello_world + i*shot_rotation), total_time/(num_shots-1), Color.DARK_BLUE, [0, 0, "Rear Lasers"], false)
		await get_tree().create_timer(total_time/(num_shots-1)).timeout
	
	await get_tree().create_timer(1.5).timeout
	omega_halo.queue_free()


# Beetle Omega stuff
func play_beetle_spawn():
	beetle_omega = BEETLE_OMEGA.instantiate()
	get_tree().current_scene.add_child(beetle_omega)
	beetle_omega.visible = false
	beetle_omega.global_position = SPos.BEETLE_OMEGA_SPAWN_POS.rotated(Vector3.UP, -rotation_protean)
	beetle_omega.rotation.y += PI/2-rotation_protean
	beetle_omega.play_arrive()

func play_spawn_towers():
	beetle_omega.play_spawn_fists()

func play_beetle_leave():
	beetle_omega.play_leave()
	await get_tree().create_timer(1.5).timeout
	beetle_omega.queue_free()




# party movement stuff

func move_playstation_conga():
	var all_pairs = blue_pair + purple_pair + orange_pair + green_pair
	for i in range(all_pairs.size()):
		party[all_pairs[i]].move_to(SPos.PLAYSTATION_CONGA[i].rotated(rotation_protean))

func move_proteans():
	var pos
	if remote:
		pos = SPos.REMOTE_GLITCH_PROTEAN_POS
		for key in all_keys:
			party[key].set_sprint()
	else:
		pos = SPos.MID_GLITCH_PROTEAN_POS
	
	var north_double_taken = false
	
	bait_idx = blue_pair.find(laser_bait_1)
	if bait_idx != -1:
		party[blue_pair[bait_idx]].move_to(pos["north_single_unmarked"].rotated(rotation_protean))
		party[blue_pair[(bait_idx+1) % 2]].move_to(pos["north_single_marked"].rotated(rotation_protean))
		set_marker(blue_pair[bait_idx], "4")
		set_marker(blue_pair[(bait_idx+1) % 2], "2")
	else:
		party[blue_pair[0]].move_to(pos["north_double_left"].rotated(rotation_protean))
		party[blue_pair[1]].move_to(pos["north_double_right"].rotated(rotation_protean))
		set_marker(blue_pair[0], "A")
		set_marker(blue_pair[1], "C")
		north_double_taken = true
		
	bait_idx = purple_pair.find(laser_bait_1)
	if bait_idx != -1:
		party[purple_pair[bait_idx]].move_to(pos["north_single_unmarked"].rotated(rotation_protean))
		party[purple_pair[(bait_idx+1) % 2]].move_to(pos["north_single_marked"].rotated(rotation_protean))
		set_marker(purple_pair[bait_idx], "4")
		set_marker(purple_pair[(bait_idx+1) % 2], "2")
	else:
		bait_idx = purple_pair.find(laser_bait_2)
		if bait_idx != -1:
			party[purple_pair[bait_idx]].move_to(pos["south_single_unmarked"].rotated(rotation_protean))
			party[purple_pair[(bait_idx+1) % 2]].move_to(pos["south_single_marked"].rotated(rotation_protean))
			set_marker(purple_pair[bait_idx], "1")
			set_marker(purple_pair[(bait_idx+1) % 2], "3")
		elif !north_double_taken:
			party[purple_pair[0]].move_to(pos["north_double_left"].rotated(rotation_protean))
			party[purple_pair[1]].move_to(pos["north_double_right"].rotated(rotation_protean))
			set_marker(purple_pair[0], "A")
			set_marker(purple_pair[1], "C")
			north_double_taken = true
		else:
			party[purple_pair[0]].move_to(pos["south_double_left"].rotated(rotation_protean))
			party[purple_pair[1]].move_to(pos["south_double_right"].rotated(rotation_protean))
			set_marker(purple_pair[0], "D")
			set_marker(purple_pair[1], "B")
	
	bait_idx = orange_pair.find(laser_bait_1)
	if bait_idx != -1:
		party[orange_pair[bait_idx]].move_to(pos["north_single_unmarked"].rotated(rotation_protean))
		party[orange_pair[(bait_idx+1) % 2]].move_to(pos["north_single_marked"].rotated(rotation_protean))
		set_marker(orange_pair[bait_idx], "4")
		set_marker(orange_pair[(bait_idx+1) % 2], "2")
	else:
		bait_idx = orange_pair.find(laser_bait_2)
		if bait_idx != -1:
			party[orange_pair[bait_idx]].move_to(pos["south_single_unmarked"].rotated(rotation_protean))
			party[orange_pair[(bait_idx+1) % 2]].move_to(pos["south_single_marked"].rotated(rotation_protean))
			set_marker(orange_pair[bait_idx], "1")
			set_marker(orange_pair[(bait_idx+1) % 2], "3")
		elif !north_double_taken:
			party[orange_pair[0]].move_to(pos["north_double_left"].rotated(rotation_protean))
			party[orange_pair[1]].move_to(pos["north_double_right"].rotated(rotation_protean))
			set_marker(orange_pair[0], "A")
			set_marker(orange_pair[1], "C")
			north_double_taken = true
		else:
			party[orange_pair[0]].move_to(pos["south_double_left"].rotated(rotation_protean))
			party[orange_pair[1]].move_to(pos["south_double_right"].rotated(rotation_protean))
			set_marker(orange_pair[0], "D")
			set_marker(orange_pair[1], "B")	
	
	bait_idx = green_pair.find(laser_bait_2)
	if bait_idx != -1:
		party[green_pair[bait_idx]].move_to(pos["south_single_unmarked"].rotated(rotation_protean))
		party[green_pair[(bait_idx+1) % 2]].move_to(pos["south_single_marked"].rotated(rotation_protean))
		set_marker(green_pair[bait_idx], "1")
		set_marker(green_pair[(bait_idx+1) % 2], "3")
	else:
		party[green_pair[0]].move_to(pos["south_double_left"].rotated(rotation_protean))
		party[green_pair[1]].move_to(pos["south_double_right"].rotated(rotation_protean))
		set_marker(green_pair[0], "D")
		set_marker(green_pair[1], "B")
			
func set_marker(key: String, initial_marker: String):
	var rotation_shift = int(rotation_protean / (PI/4))
	var marker_to_idx = {
		"A": 0, "1": 1, "B": 2, "2": 3, "C": 4, "3": 5, "D": 6, "4": 7
	}
	var marker_list = ["A", "1", "B", "2", "C", "3", "D", "4"] # clockwise from N
	
	protean_marker[key] = marker_list[(marker_to_idx[initial_marker] + rotation_shift) % 8]

func mark_players():
	if Global.p5_disable_markers:
		return
	var copy_dynamis_starters = dynamis_starters.duplicate()
	var zero_stack: Array = []
	for key in party:
		if key == near_key or key == far_key:
			copy_dynamis_starters.erase(key)
		elif !copy_dynamis_starters.has(key):
			zero_stack.append(key)
	copy_dynamis_starters.shuffle()
	
	if !random:
		copy_dynamis_starters.erase(player_key)
		zero_stack.erase(player_key)
	
	var temp_key
	
	if bind1:
		mark_dict["bind1"] = player_key
	else:
		temp_key = copy_dynamis_starters[0]
		mark_dict["bind1"] = temp_key
		copy_dynamis_starters.erase(temp_key)
	if bind2:
		mark_dict["bind2"] = player_key
	else:
		temp_key = copy_dynamis_starters[0]
		mark_dict["bind2"] = temp_key
		copy_dynamis_starters.erase(temp_key)
	if target1:
		mark_dict["target1"] = player_key
	else:
		temp_key = copy_dynamis_starters[0]
		mark_dict["target1"] = temp_key
		copy_dynamis_starters.erase(temp_key)
	
	copy_dynamis_starters = copy_dynamis_starters + zero_stack
	copy_dynamis_starters.shuffle()
	
	
	if target2:
		mark_dict["target2"] = player_key
	else:
		temp_key = copy_dynamis_starters[0]
		mark_dict["target2"] = temp_key
		copy_dynamis_starters.erase(temp_key)
	if target3:
		mark_dict["target3"] = player_key
	else:
		temp_key = copy_dynamis_starters[0]
		mark_dict["target3"] = temp_key
		copy_dynamis_starters.erase(temp_key)
	if target4:
		mark_dict["target4"] = player_key
	else:
		temp_key = copy_dynamis_starters[0]
		mark_dict["target4"] = temp_key
		copy_dynamis_starters.erase(temp_key)
		
	mark_dict["near"] = near_key
	mark_dict["far"] = far_key
	
	lockon_controller.add_marker("Mark_Triangle", party[near_key])
	lockon_controller.add_marker("Mark_Plus", party[far_key])
	lockon_controller.add_marker("Link_1", party[mark_dict["bind1"]])
	lockon_controller.add_marker("Link_2", party[mark_dict["bind2"]])
	lockon_controller.add_marker("Target_1", party[mark_dict["target1"]])
	lockon_controller.add_marker("Target_2", party[mark_dict["target2"]])
	lockon_controller.add_marker("Target_3", party[mark_dict["target3"]])
	lockon_controller.add_marker("Target_4", party[mark_dict["target4"]])

func unmark_players():
	if Global.p5_disable_markers:
		return
	lockon_controller.remove_marker("Mark_Triangle", party[near_key])
	lockon_controller.remove_marker("Mark_Plus", party[far_key])
	lockon_controller.remove_marker("Link_1", party[mark_dict["bind1"]])
	lockon_controller.remove_marker("Link_2", party[mark_dict["bind2"]])
	lockon_controller.remove_marker("Target_1", party[mark_dict["target1"]])
	lockon_controller.remove_marker("Target_2", party[mark_dict["target2"]])
	lockon_controller.remove_marker("Target_3", party[mark_dict["target3"]])
	lockon_controller.remove_marker("Target_4", party[mark_dict["target4"]])

func move_center():
	for key in party:
		party[key].move_to(Vector2(0, 0))

func move_knockback():
	var pos: Dictionary
	for key in party:
		if remote:
			pos = SPos.REMOTE_GLITCH_KNOCKBACK_POS
			party[key].move_to(pos[protean_marker[key]].rotated(rotation_protean+rotation_tower))
		else:
			pos = SPos.MID_GLITCH_KNOCKBACK_POS
			party[key].move_to(pos[protean_marker[key]].rotated(rotation_protean+rotation_tower))

func move_tower_soak():
	var pos: Dictionary
	for key in party:
		if remote:
			pos = SPos.REMOTE_GLITCH_SOAK_POS
			party[key].move_to(pos[protean_marker[key]].rotated(rotation_protean+rotation_tower))
		else:
			pos = SPos.MID_GLITCH_SOAK_POS
			party[key].move_to(pos[protean_marker[key]].rotated(rotation_protean+rotation_tower))

func move_line_wait():
	var pos: Dictionary
	if clockwise:
		pos = SPos.CLOCKWISE_POS
		for key in mark_dict:
			if key == "bind1" or key == "bind2" or key == "target1":
				party[mark_dict[key]].move_to(pos["north"].rotated(rotation_hello_world))
			else:
				party[mark_dict[key]].move_to(pos["south"].rotated(rotation_hello_world))
	else:
		pos = SPos.ANTICLOCKWISE_POS
		for key in mark_dict:
			if key == "bind1" or key == "bind2" or key == "target1":
				party[mark_dict[key]].move_to(pos["north"].rotated(rotation_hello_world))
			else:
				party[mark_dict[key]].move_to(pos["south"].rotated(rotation_hello_world))

func move_cleave():
	if wait:
		return
	else:
		var pos: Dictionary = SPos.SKATE_POS
		for key in mark_dict:
			if key == "bind1" or key == "bind2" or key == "target1":
				party[mark_dict[key]].rotate_to(pos["north"].rotated(rotation_hello_world))
			else:
				party[mark_dict[key]].rotate_to(pos["south"].rotated(rotation_hello_world))

func move_hello_world():
	var pos: Dictionary = SPos.HELLO_WORLD_POS
	party[mark_dict["target1"]].move_to(pos["target1"].rotated(rotation_hello_world))
	party[mark_dict["target4"]].move_to(pos["target4"].rotated(rotation_hello_world))
	party[mark_dict["far"]].move_to(pos["far"].rotated(rotation_hello_world))
	if clockwise:
		party[mark_dict["bind2"]].rotate_to(pos["bind2"].rotated(rotation_hello_world))
		party[mark_dict["bind1"]].rotate_to(SPos.BIND_WAIT_POS["bind1"].rotated(rotation_hello_world))
		party[mark_dict["target2"]].rotate_to(pos["target2_cw"].rotated(rotation_hello_world))
		party[mark_dict["target3"]].rotate_to(pos["target3_cw"].rotated(rotation_hello_world))
		await get_tree().create_timer(1.0).timeout
		party[mark_dict["near"]].move_to(pos["near_cw"].rotated(rotation_hello_world))
		await get_tree().create_timer(3.0).timeout
		party[mark_dict["bind1"]].move_to(pos["bind1"].rotated(rotation_hello_world))
	else:
		party[mark_dict["bind1"]].rotate_to(pos["bind1"].rotated(rotation_hello_world))
		party[mark_dict["bind2"]].rotate_to(SPos.BIND_WAIT_POS["bind2"].rotated(rotation_hello_world))
		party[mark_dict["target2"]].rotate_to(pos["target2_ccw"].rotated(rotation_hello_world))
		party[mark_dict["target3"]].rotate_to(pos["target3_ccw"].rotated(rotation_hello_world))
		await get_tree().create_timer(1.0).timeout
		party[mark_dict["near"]].move_to(pos["near_ccw"].rotated(rotation_hello_world))
		await get_tree().create_timer(4.0).timeout
		party[mark_dict["bind2"]].move_to(pos["bind2"].rotated(rotation_hello_world))
