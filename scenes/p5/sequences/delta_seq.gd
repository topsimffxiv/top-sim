extends Node

var debug = false

const LOCAL_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/common/local_code_smell.tscn")
const LOCAL_REGRESSION = preload("res://scenes/ui/auras/debuff_icons/common/local_regression.tscn")
const REMOTE_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/common/remote_code_smell.tscn")
const REMOTE_REGRESSION = preload("res://scenes/ui/auras/debuff_icons/common/remote_regression.tscn")
const HELLO_NEAR_WORLD = preload("res://scenes/ui/auras/debuff_icons/p5/hello_near_world.tscn")
const HELLO_DISTANT_WORLD = preload("res://scenes/ui/auras/debuff_icons/p5/hello_distant_world.tscn")
const OVERSAMPLED_WAVE_CANNON_LOADING = preload("res://scenes/ui/auras/debuff_icons/common/oversampled_wave_cannon_loading.tscn")
const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const THRICE_COME_RUIN = preload("res://scenes/ui/auras/debuff_icons/common/thrice_come_ruin.tscn")
const QUICKENING_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p5/quickening_dynamis.tscn")

var OMEGA_M_GOLD = preload("res://scenes/p5/enemies/omega_m_gold.tscn")
var HITBOX_RING = preload("res://scenes/common/enemies/hitbox_ring.tscn")
var ARENA_EYE = preload("res://scenes/p2/enemies/arena_eye.tscn")
var BEETLE_OMEGA = preload("res://scenes/p1/enemies/beetle_omega.tscn")
var FINAL_OMEGA = preload("res://scenes/p3/enemies/final_omega.tscn")
var YELLOW_FIST = preload("res://scenes/p5/enemies/omega_rocket_punch_yellow.tscn")
var BLUE_FIST = preload("res://scenes/p5/enemies/omega_rocket_punch_blue.tscn")
var SPINNY_ANTI = preload("res://scenes/p5/enemies/anticlockwise_spinny.tscn")
var SPINNY = preload("res://scenes/p5/enemies/clockwise_spinny.tscn")
var LEFT_ARM = preload("res://scenes/p3/enemies/left_arm_unit.tscn")
var RIGHT_ARM = preload("res://scenes/p3/enemies/right_arm_unit.tscn")

const SWIVEL_CANNON_WIDTH = 95.0
const HELLO_WORLD_RADIUS_INITIAL = 19.0
const HELLO_WORLD_RADIUS = 8.0
const HELLO_WORLD_DELAY = 1.20

# enemy instances, don't instantiate til needed
var omega_m_gold
var beetle_omega
var final_omega
var arena_eye
var omega_f_gold

@onready var delta_anim: AnimationPlayer = %DeltaAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var chains_controller: ChainsController = %ChainsController
@onready var fail_list: FailList = %FailList

var rotation # scalar rotation value
var opposite_partner # if true, tether pairs have opposite color fists to each other
var left_omega_monitor # if true, final omega casts left monitor (blue safe north)
var left_player_monitor # if true, player casts left monitor
var starboard # if true, north is safe for hello world debuffs
var beyond_defense_key # key of player hit with beyond defense

var party
var player_key
var pairs

var random = true
var outer = false
var inner = false
var green = false
var blue = false
var monitor = false
var beyond = false
var near = false
var far = false

var outer_green: Array
var inner_green: Array
var outer_blue: Array
var inner_blue: Array
var monitor_key: String
var near_key: String
var far_key: String
var blue_nothings_keys: Array

var y = []
var b = []
var colors = ["", "", "", "", "", "", "", ""] # list of fist colors in order of outer green, 
var arms = [] # arms, clockwise from NW
var is_clockwise = [] # clockwise from NW, if true, arm is clockwise
var spinners = []
var monitors = []

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle"])
	lockon_controller.pre_load(["Left_Oversampled_Wave_Cannon", "Right_Oversampled_Wave_Cannon"])
	chains_controller.pre_load(["local_code_smell", "remote_code_smell", "local_regression", "remote_regression"])
	chains_controller.patch_activated.connect(on_patch_activated)
	instantiate_party(new_party)
	delta_anim.play("delta_anim")
	
	#spawn_bosses()
	#spawn_arms()
	#spawn_spinners()
	#await get_tree().create_timer(6.0).timeout
	#snapshot_arms()
	
	# spawn gold omega_m
	omega_m_gold = OMEGA_M_GOLD.instantiate()
	get_tree().current_scene.add_child(omega_m_gold)
	omega_m_gold.visible = true
	omega_m_gold.play_start_sword()
	omega_m_gold.global_rotation = Vector3(0, PI/2, 0)
	omega_m_gold.scale = 6*Vector3(1, 1, 1)
	
	#await get_tree().create_timer(3.0).timeout
	#spawn_fists()
	#await get_tree().create_timer(3.0).timeout
	#snapshot_fists()
	#await get_tree().create_timer(2.4).timeout
	#move_fists()
	
func instantiate_party(new_party: Dictionary):
	party = new_party
	assign_role()
	
	randomize()
	rotation = randi_range(0, 3) * PI/2 # scalar rotation value
	opposite_partner =  randf() > 0.5 # if true, tether pairs have opposite color fists to each other
	left_omega_monitor = randf() > 0.5 # if true, omega casts left monitor (blue safe north)
	left_player_monitor = randf() > 0.5 # if true, player casts left monitor
	starboard = randf() > 0.5 # if true, north is safe for hello world debuffs
	
	if debug:
		rotation = 0
		left_omega_monitor = true
		left_player_monitor = true
		starboard = true
	
	# setup tether pairs
	pairs = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	for key in pairs:
		if party[key].is_player():
			player_key = key
	if !random:
		pairs.erase(player_key)
	pairs.shuffle()
	if blue:
		if outer:
			pairs.insert(randi_range(4, 5), player_key)
		elif inner:
			if randf() > 0.5:
				pairs.insert(6, player_key)
			else:
				pairs.append(player_key)
		else:
			if randf() > 0.25:
				pairs.insert(randi_range(4, 6), player_key)
			else:
				pairs.append(player_key)
	if green:
		if outer:
			pairs.insert(randi_range(0, 1), player_key)
		else:
			pairs.insert(randi_range(2, 3), player_key)
	outer_green = [pairs[0], pairs[1]]
	inner_green = [pairs[2], pairs[3]]
	outer_blue = [pairs[4], pairs[5]]
	inner_blue = [pairs[6], pairs[7]]
	
	var blues = outer_blue + inner_blue
	# choose monitor
	if monitor:
		monitor_key = player_key
		print(monitor_key)
	else:
		monitor_key = blues[randi_range(0, 3)]
		
	# choose near/far
	if near:
		near_key = player_key
		blues.erase(player_key)
		far_key = blues[randi_range(0, 2)]
	elif far:
		far_key = player_key
		blues.erase(player_key)
		near_key = blues[randi_range(0, 2)]
	else:
		near_key = blues[randi_range(0, 3)]
		blues.erase(near_key)
		far_key = blues[randi_range(0, 2)]	
	
	blue_nothings_keys = outer_blue + inner_blue
	blue_nothings_keys.erase(near_key)
	blue_nothings_keys.erase(far_key) # blue nothings boys
	
	
	if random: # if randomly assigning, then give healers middle prio, otherwise don't bother
		if outer_green.has("h1"):
			var tmp = inner_green
			inner_green = outer_green
			outer_green = tmp
		elif outer_green.has("h2") and !inner_green.has("h1"):
			var tmp = inner_green
			inner_green = outer_green
			outer_green = tmp
		if outer_blue.has("h1"):
			var tmp = inner_blue
			inner_blue = outer_blue
			outer_blue = tmp
		elif outer_blue.has("h2") and !inner_blue.has("h1"):
			var tmp = inner_blue
			inner_blue = outer_blue
			outer_blue = tmp
	pairs = outer_green + inner_green + outer_blue + inner_blue # re-center pairs to standard order in original array

func assign_role():
	if Global.p5_delta_selected_debuff == 0 and !Global.p5_force_monitor and !Global.p5_force_beyond_defense:
		return
	random = false
	if Global.p5_delta_selected_debuff == 1:
		outer = true
		green = true
	elif Global.p5_delta_selected_debuff == 2:
		inner = true
		green = true
	elif Global.p5_delta_selected_debuff == 3:
		outer = true
		blue = true
	elif Global.p5_delta_selected_debuff == 4:
		inner = true
		blue = true
	elif Global.p5_delta_selected_debuff == 5:
		near = true
		blue = true
	elif Global.p5_delta_selected_debuff == 6:
		far = true
		blue = true
	else:
		print("delta role selection out of bounds")
		
	if Global.p5_force_monitor:
		monitor = true
		blue = true
		green = false
	if Global.p5_force_beyond_defense:
		beyond = true
		blue = true
		green = false
		inner = true
		outer = false

func spawn_debuffs():
	spawn_local_code_smell(party[pairs[0]], party[pairs[1]], 18.0)
	spawn_local_code_smell(party[pairs[2]], party[pairs[3]], 18.0)
	spawn_remote_code_smell(party[pairs[4]], party[pairs[5]], 18.0)
	spawn_remote_code_smell(party[pairs[6]], party[pairs[7]], 18.0)
	var near_world = party[near_key].add_debuff(HELLO_NEAR_WORLD, 44.0, false, "Hello, Near World")
	near_world.connect(snapshot_near_world)
	var far_world = party[far_key].add_debuff(HELLO_DISTANT_WORLD, 44.0, false, "Hello, Distant World")
	far_world.connect(snapshot_distant_world)

func spawn_fists():
	for i in range(0, 4):
		y.append(YELLOW_FIST.instantiate())
		b.append(BLUE_FIST.instantiate())
		get_tree().current_scene.add_child(y[i])
		get_tree().current_scene.add_child(b[i])
		if opposite_partner:	
			var j = randi_range(0, 1)
			y[i].set_parameters(party[pairs[2*i + j]])
			colors[2*i + j] = "yellow"
			b[i].set_parameters(party[pairs[2*i + (j+1)%2]])
			colors[2*i + (j+1)%2] = "blue"
	if !opposite_partner:
		if randf() > 0.5:
			for k in range(2):
				y[k].set_parameters(party[outer_green[k]])
				colors[k] = "yellow"
				b[k].set_parameters(party[inner_green[k]])
				colors[k+2] = "blue"
		else:
			for k in range(2):
				y[k].set_parameters(party[inner_green[k]])
				colors[k+2] = "yellow"
				b[k].set_parameters(party[outer_green[k]])
				colors[k] = "blue"
		if randf() > 0.5:
			for k in range(2, 4):
				y[k].set_parameters(party[outer_blue[k-2]])
				colors[k+2] = "yellow"
				b[k].set_parameters(party[inner_blue[k-2]])
				colors[k+4] = "blue"
		else:
			for k in range(2, 4):
				y[k].set_parameters(party[inner_blue[k-2]])
				colors[k+4] = "yellow"
				b[k].set_parameters(party[outer_blue[k-2]])	
				colors[k+2] = "blue"

func snapshot_fists():
	var y_locs = []
	var b_locs = []
	for i in range(0, 4):
		y_locs.append(y[i].snapshot_target_area())
		b_locs.append(b[i].snapshot_target_area())
	await get_tree().create_timer(1.2).timeout
	for yloc in y_locs:
		var satisfied = false
		for bloc in b_locs:
			if yloc.distance_to(bloc) < 5.0:
				satisfied = true
				spawn_fist_aoe(yloc, bloc)
				b_locs.erase(bloc)
				break
		if !satisfied:
			fail_list.add_fail("Rocket Punch not paired correctly")

func spawn_fist_aoe(yloc, bloc):
	ground_aoe_controller.spawn_circle(Vector2(yloc.x, yloc.z), 5.0, 2.40, Color.GOLDENROD, [0, 0, "Explosion"], true)
	ground_aoe_controller.spawn_circle(Vector2(bloc.x, bloc.z), 5.0, 2.40, Color.GOLDENROD, [0, 0, "Explosion"], true)

func move_fists():
	for i in range(0, 4):
		y[i].move()
		b[i].move()


func spawn_arms():
	for i in range(0, 3):
		arms.append(LEFT_ARM.instantiate())
		arms.append(RIGHT_ARM.instantiate())
	for i in range(0, 6):
		get_tree().current_scene.add_child(arms[i])
		arms[i].global_position = DPos.HAND_SPAWN_POS[i].rotated(Vector3.UP, -rotation)
		arms[i].rotation = Vector3(0, -PI/6 - i*PI/3 - rotation, 0)
	
func spawn_spinners():
	var bottom_clockwise
	var left
	var mid
	var right = randf() > 0.75
	if right:
		left = right
	else:
		left = randf() > 0.333
	if left == right:
		mid = !right
	else:
		mid = randf() > 0.5
	bottom_clockwise = [right, mid, left]
	
	var top_clockwise
	left = randf() > 0.75
	if left:
		right = left
	else:
		right = randf() > 0.333
	if left == right:
		mid = !right
	else:
		mid = randf() > 0.5
	top_clockwise = [left, mid, right]
	
	is_clockwise = top_clockwise + bottom_clockwise
	
	for i in range(6):
		if is_clockwise[i]:
			spinners.append(SPINNY.instantiate())
		else:
			spinners.append(SPINNY_ANTI.instantiate())
		get_tree().current_scene.add_child(spinners[i])
		spinners[i].global_position = DPos.HAND_SPAWN_POS[i].rotated(Vector3.UP, -rotation)
	
func hide_spinners():
	for spinner in spinners:
		spinner.visible = false
		spinner.queue_free()
	
func snapshot_arms():
	var sign_rotation
	var positions = []
	for i in range(6):
		var closest_key = get_closest_key(arms[i].get_pos(), ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"])
		arms[i].look_at(party[closest_key].global_position)
		arms[i].rotation += Vector3(0, PI, 0)
		positions.append(Vector2(party[closest_key].global_position.x, party[closest_key].global_position.z))
		ground_aoe_controller.spawn_line(arms[i].get_pos(), 16.0, 100.0, positions[i], 2.30, Color.GOLDENROD, [0, 0, "Hyper Pulse"], true)
	await get_tree().create_timer(2.30).timeout
	var angle_delta = deg_to_rad(20) # angle between each pulse
	var pulse_time = 0.55 # seconds between pulse snapshot

	for pulse_num in range(0, 6):
		for i in range(6):
			if is_clockwise[i]:
				sign_rotation = 1.0
			else:
				sign_rotation = -1.0
			if pulse_num != 0:
				arms[i].rotation += Vector3(0, -sign_rotation * angle_delta, 0)
			arms[i].play_laser_blast()
			var center = arms[i].get_pos()
			var diff = positions[i] - center
			var target = diff.rotated(sign_rotation*(pulse_num)*angle_delta) + center
			ground_aoe_controller.spawn_line(center, 16.0, 100.0, target, pulse_time, Color.DODGER_BLUE, [0, 0, "Hyper Pulse"], false)
		await get_tree().create_timer(pulse_time).timeout

func spawn_monitors():
	if left_player_monitor:
		monitors.append(lockon_controller.add_marker("Left_Oversampled_Wave_Cannon", party[monitor_key]))
	else:
		monitors.append(lockon_controller.add_marker("Right_Oversampled_Wave_Cannon", party[monitor_key]))
	monitors[0].set_holder(party[monitor_key])
	party[monitor_key].add_debuff(OVERSAMPLED_WAVE_CANNON_LOADING, 10000.0, false, "Oversampled Wave Cannon Loading")
	await get_tree().create_timer(1.0).timeout
	var omega_monitor
	if left_omega_monitor:
		omega_monitor = lockon_controller.add_marker("Left_Oversampled_Wave_Cannon", final_omega)
		omega_monitor.set_holder(final_omega)
	else:
		omega_monitor = lockon_controller.add_marker("Right_Oversampled_Wave_Cannon", final_omega)
		omega_monitor.set_holder(final_omega)
	omega_monitor.scale = Vector3(1, 1, 1) * 3.5
	omega_monitor.global_position = final_omega.global_position
	omega_monitor.get_node("FrontLine").visible = false
	omega_monitor.get_node("BackLine").visible = false
	monitors.append(omega_monitor)

func cast_oversampled_wave_cannon():
	if left_omega_monitor:
		final_omega.play_left_monitor()
	else:
		final_omega.play_right_monitor()
		
func snapshot_monitors():
	for i in range(0, monitors.size()):
		var bodies = monitors[i].bodies
		if bodies.size() < 2:
			if i < 3:
				fail_list.add_fail("Not enough targets for monitor %s" % (i+1))
			else:
				fail_list.add_fail("Not enough targets for Final Omega monitor")
			if bodies.size() == 0:
				bodies.append(party[outer_green[0]])
			bodies.append(party[inner_green[1]])	
		if bodies.size() > 2:
			if i < 3:
				fail_list.add_fail("Too many targets for monitor %s" % (i+1))
			else:
				fail_list.add_fail("Too many targets for Final Omega monitor")
			while bodies.size() > 2:
				bodies.remove_at(randi_range(0, bodies.size()-1))
		for body in bodies:
			ground_aoe_controller.spawn_circle(body.get_pos(), 16.0, 0.3, Color.AQUA, [1, 1, "Oversampled Wave Cannon"], false, 0.5)
			body.add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")
			body.add_debuff(THRICE_COME_RUIN, 7.0, true, "Thrice Come Ruin")
		monitors[i].visible = false
	party[monitor_key].remove_debuff("Oversampled Wave Cannon Loading")
	for key in pairs:
		if party[key].get_debuff_stacks("Thrice Come Ruin") >= 3:
			fail_list.add_fail(str(party[key].to_string(), " got too many doom stacks"))

func hide_final_and_arms():
	final_omega.visible = false
	final_omega.queue_free()
	for arm in arms:
		arm.visible = false
		arm.queue_free()


func snapshot_near_world(_owner_key):
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	var second_target_key_list = all_keys.duplicate()
	second_target_key_list.erase(near_key)
	var second_target_key = get_closest_key(party[near_key].get_pos(), second_target_key_list)
	ground_aoe_controller.spawn_circle(party[near_key].get_pos(), HELLO_WORLD_RADIUS_INITIAL, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[near_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	print(party[near_key])
	print(party[second_target_key])
	party[near_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[second_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[second_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[second_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	all_keys.erase(second_target_key)
	var third_target_key = get_closest_key(party[second_target_key].get_pos(), all_keys)
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[third_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Near World"], false)
	party[third_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[third_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")
	
func snapshot_distant_world(_owner_key):
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
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
	all_keys.erase(second_target_key)
	var third_target_key = get_furthest_key(party[second_target_key].get_pos(), all_keys)
	
	await get_tree().create_timer(HELLO_WORLD_DELAY).timeout
	ground_aoe_controller.spawn_circle(party[third_target_key].get_pos(), HELLO_WORLD_RADIUS, 0.5, Color.GOLDENROD, [1, 1, "Hello, Distant World"], false)
	party[third_target_key].add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability Up")
	party[third_target_key].add_debuff(QUICKENING_DYNAMIS, 10000.0, true, "Quickening Dynamis")


func spawn_local_regression(source: Node3D, target: Node3D, duration: float) -> LocalRegression:
	var chain = chains_controller.spawn_local_regression(source, target)
	var source_signal = source.add_debuff(LOCAL_REGRESSION, duration, false, "Local Regression")
	var target_signal = target.add_debuff(LOCAL_REGRESSION, duration, false, "Local Regression")
	source_signal.connect(local_regression_timeout)
	target_signal.connect(local_regression_timeout)
	return chain

func spawn_local_code_smell(source: Node3D, target: Node3D, duration: float) -> LocalCodeSmell:
	var chain = chains_controller.spawn_local_code_smell(source, target, duration)
	var source_signal = source.add_debuff(LOCAL_CODE_SMELL, duration, false, "Local Code Smell")
	var target_signal = target.add_debuff(LOCAL_CODE_SMELL, duration, false, "Local Code Smell")
	source_signal.connect(local_code_smell_timeout)
	target_signal.connect(local_code_smell_timeout)
	source.get_debuff("Local Code Smell").local_code_smell_toggle_visible.connect(on_local_code_smell_toggle_visible)
	target.get_debuff("Local Code Smell").local_code_smell_toggle_visible.connect(on_local_code_smell_toggle_visible)
	return chain

func local_code_smell_timeout(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("LocalCodeSmellMesh")
	if !chain:
		return
	spawn_local_regression(chain.source, chain.target, 36.0)
	chains_controller.remove_chain(chain)
	return

func on_local_code_smell_toggle_visible(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("LocalCodeSmellMesh")
	if !chain:
		return
	chain.visible = true

func spawn_remote_code_smell(source: Node3D, target: Node3D, duration: float) -> RemoteCodeSmell:
	var chain = chains_controller.spawn_remote_code_smell(source, target, duration)
	var source_signal = source.add_debuff(REMOTE_CODE_SMELL, duration, false, "Remote Code Smell")
	var target_signal = target.add_debuff(REMOTE_CODE_SMELL, duration, false, "Remote Code Smell")
	source_signal.connect(remote_code_smell_timeout)
	target_signal.connect(remote_code_smell_timeout)
	source.get_debuff("Remote Code Smell").remote_code_smell_toggle_visible.connect(on_remote_code_smell_toggle_visible)
	target.get_debuff("Remote Code Smell").remote_code_smell_toggle_visible.connect(on_remote_code_smell_toggle_visible)
	return chain

func spawn_remote_regression(source: Node3D, target: Node3D, duration: float) -> RemoteRegression:
	var chain = chains_controller.spawn_remote_regression(source, target)
	var source_signal = source.add_debuff(REMOTE_REGRESSION, duration, false, "Remote Regression")
	var target_signal = target.add_debuff(REMOTE_REGRESSION, duration, false, "Remote Regression")
	source_signal.connect(remote_regression_timeout)
	target_signal.connect(remote_regression_timeout)
	return chain

func remote_code_smell_timeout(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("RemoteCodeSmellMesh")
	if !chain:
		return
	
	spawn_remote_regression(chain.source, chain.target, 36.0)
	chains_controller.remove_chain(chain)

func on_remote_code_smell_toggle_visible(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("RemoteCodeSmellMesh")
	if !chain:
		return
	chain.visible = true
	
func remote_regression_timeout(owner_key: String) -> void:
	fail_list.add_fail("Remote Regression expired: %s" % party[owner_key].get_name())
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("RemoteRegressionMesh")
	if !chain:
		return
	chains_controller.remove_chain(chain)
	return

func local_regression_timeout(owner_key: String) -> void:
	fail_list.add_fail("Local Regression expired: %s" % party[owner_key].get_name())
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("LocalRegressionMesh")
	if !chain:
		return
	chains_controller.remove_chain(chain)
	return

func on_patch_activated(target: Node3D, source: Node3D) -> void:
	var players = []
	for key in party:
		players.append(party[key])
	ground_aoe_controller.spawn_circle(Vector2(target.global_position.x, target.global_position.z), 7.0, 0.3,\
		Color.IVORY, [0, 0, "Patch", players])
	ground_aoe_controller.spawn_circle(Vector2(source.global_position.x, source.global_position.z), 7.0, 0.3,\
		Color.IVORY, [0, 0, "Patch", players])
	for key in pairs:
		if party[key].get_debuff_stacks("Thrice Come Ruin") >= 3:
			fail_list.add_fail(str(party[key].to_string(), " got too many doom stacks"))


func show_omega_m():
	omega_m_gold.visible = true
	
func snapshot_beyond_defense():
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	var close_key1 = get_closest_key(Vector2(0, 0), all_keys)
	all_keys.erase(close_key1)
	var close_key2 = get_closest_key(Vector2(0, 0), all_keys)
	
	
	if beyond:
		ground_aoe_controller.spawn_circle(party[player_key].get_pos(), 10.0, 0.3, Color.TRANSPARENT, [1, 1, "Beyond Defense"], false)
		party[close_key1].add_debuff(THRICE_COME_RUIN, 7.0, true, "Thrice Come Ruin")
		beyond_defense_key = player_key
		await get_tree().create_timer(1.0).timeout
		ground_aoe_controller.spawn_circle(party[player_key].get_pos(), 10.0, 0.3, Color.GOLDENROD, [1, 8, "Beyond Defense"], false)
	
	elif randf() > 0.5:
		ground_aoe_controller.spawn_circle(party[close_key1].get_pos(), 10.0, 0.3, Color.TRANSPARENT, [1, 8, "Beyond Defense"], false)
		party[close_key1].add_debuff(THRICE_COME_RUIN, 7.0, true, "Thrice Come Ruin")
		beyond_defense_key = close_key1
		await get_tree().create_timer(1.0).timeout
		ground_aoe_controller.spawn_circle(party[close_key1].get_pos(), 10.0, 0.3, Color.GOLDENROD, [1, 8, "Beyond Defense"], false)

	else:
		ground_aoe_controller.spawn_circle(party[close_key2].get_pos(), 10.0, 0.3, Color.TRANSPARENT, [1, 1, "Beyond Defense"], false)
		party[close_key2].add_debuff(THRICE_COME_RUIN, 7.0, true, "Thrice Come Ruin")
		beyond_defense_key = close_key2
		await get_tree().create_timer(1.0).timeout
		ground_aoe_controller.spawn_circle(party[close_key2].get_pos(), 10.0, 0.3, Color.GOLDENROD, [1, 8, "Beyond Defense"], false)
		
	for key in pairs:
		if party[key].get_debuff_stacks("Thrice Come Ruin") >= 3:
			fail_list.add_fail(str(party[key].to_string(), " got too many doom stacks"))
	
func snapshot_pile_pitch():
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	var close_key1 = get_closest_key(Vector2(0, 0), all_keys)
	all_keys.erase(close_key1)
	var close_key2 = get_closest_key(Vector2(0, 0), all_keys)
	if randf() > 0.5:
		var stack = ground_aoe_controller.spawn_circle(party[close_key1].get_pos(), 10.0, 0.3, Color.GOLDENROD, [3, 3, "Pile Pitch"])
		stack.collisions_checked.connect(_on_pile_pitch_collision)

	else:
		var stack = ground_aoe_controller.spawn_circle(party[close_key2].get_pos(), 10.0, 0.3, Color.GOLDENROD, [3, 3, "Pile Pitch"])
		stack.collisions_checked.connect(_on_pile_pitch_collision)

func _on_pile_pitch_collision(bodies: Array):
	for body in bodies:
		body.add_debuff(THRICE_COME_RUIN, 7.0, true, "Thrice Come Ruin")
		
	for key in pairs:
		if party[key].get_debuff_stacks("Thrice Come Ruin") >= 3:
			fail_list.add_fail(str(party[key].to_string(), " got too many doom stacks"))

func play_beyond_defense():
	omega_m_gold.play_beyond_defense()

func play_pile_pitch():
	omega_m_gold.play_pile_pitch()
	await get_tree().create_timer(3.0).timeout
	omega_m_gold.visible = false

func cast_run_dynamis_delta():
	cast_bar.cast("Run ****mi* (Delta Version)", 4.28)
	await get_tree().create_timer(4.28).timeout
	omega_m_gold.play_cast_dynamis()
	await omega_m_gold.animation_tree.animation_finished
	omega_m_gold.visible = false
	omega_m_gold.play_start_shield()
	omega_m_gold.global_rotation.y += rotation + PI

func spawn_bosses():
	
	arena_eye = ARENA_EYE.instantiate()
	beetle_omega = BEETLE_OMEGA.instantiate()
	final_omega = FINAL_OMEGA.instantiate()
	
	get_tree().current_scene.add_child(arena_eye)
	arena_eye.visible = false
	arena_eye.global_position = Vector3(120, 40, 0)
	arena_eye.rotation = Vector3(deg_to_rad(15), deg_to_rad(-90), 0)
	arena_eye.scale = 2*Vector3(1, 1, 1)

	get_tree().current_scene.add_child(beetle_omega)
	beetle_omega.visible = false
	beetle_omega.global_position = Vector3(0, 0, -47.5)
	
	get_tree().current_scene.add_child(final_omega)
	final_omega.visible = false
	final_omega.global_position = Vector3(0, 0, 47.5)
	final_omega.rotation = Vector3(0, PI, 0)
	final_omega.scale = 2.5*Vector3(1, 1, 1)

	arena_eye.global_position = arena_eye.global_position.rotated(Vector3.UP, -rotation)
	arena_eye.rotation.y += -rotation
	beetle_omega.global_position = beetle_omega.global_position.rotated(Vector3.UP, -rotation)
	beetle_omega.rotation.y += -rotation
	final_omega.global_position = final_omega.global_position.rotated(Vector3.UP, -rotation)
	final_omega.rotation.y += -rotation

	arena_eye.visible = true
	beetle_omega.visible = true
	final_omega.visible = true

func snapshot_eye_aoe() -> void :
	ground_aoe_controller.spawn_line(Vector2(arena_eye.global_position.x, arena_eye.global_position.z), 38, 500.0, Vector2(0, 0), 1.0, Color.AQUAMARINE, [0, 0, "Suppression"])
	await get_tree().create_timer(2.5).timeout
	arena_eye.visible = false
	arena_eye.queue_free()

func play_spawn_fists():
	beetle_omega.play_spawn_fists()

func play_swivel_cannon():
	# 9.5 seconds long
	var start = Vector3(0, 0, -47.5).rotated(Vector3.UP, -rotation)
	var end = Vector3(23.64, 0, 41.21).rotated(Vector3.UP, -rotation)
	if starboard:
		beetle_omega.show_starboard_orbs()
	else:
		end = Vector3(-23.64, 0, 41.21).rotated(Vector3.UP, -rotation)
		beetle_omega.show_larboard_orbs()
	var dir = end - start
	var offset_dir = Vector3.UP.cross(dir).normalized()
	if starboard:
		offset_dir = -offset_dir
	start += SWIVEL_CANNON_WIDTH/2 * offset_dir
	start += -20.0 * dir.normalized()
	end += SWIVEL_CANNON_WIDTH/2 * offset_dir
	end += 20.0 * dir.normalized()
	var length = start.distance_to(end)
	await get_tree().create_timer(8.0).timeout
	
	ground_aoe_controller.spawn_line(Vector2(start.x, start.z), SWIVEL_CANNON_WIDTH, length, \
				Vector2(end.x, end.z), 1.50, Color.GOLDENROD, [0, 0, "Swivel Cannon"], true)
	await get_tree().create_timer(1.50).timeout
	
	if starboard:
		beetle_omega.play_starboard()
	else:
		beetle_omega.play_larboard()

func play_beetle_leave():
	beetle_omega.play_leave()
	await get_tree().create_timer(1.0).timeout
	beetle_omega.queue_free()
	
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
			

func move_initial_tether_pos():
	for i in range(pairs.size()):
		party[pairs[i]].move_to(DPos.INITIAL_TETHER_POS[i].rotated(rotation))
		
func move_inner_adjust_pos():
	if colors[2] == colors[0]:
		inner_green.reverse()
	if colors[6] == colors[4]:
		inner_blue.reverse()
	party[inner_green[0]].move_to(DPos.INNER_TETHER_ADJUST_POS["inner_green_north"].rotated(rotation))
	party[inner_green[1]].move_to(DPos.INNER_TETHER_ADJUST_POS["inner_green_south"].rotated(rotation))
	party[inner_blue[0]].move_to(DPos.INNER_TETHER_ADJUST_POS["inner_blue_north"].rotated(rotation))
	party[inner_blue[1]].move_to(DPos.INNER_TETHER_ADJUST_POS["inner_blue_south"].rotated(rotation))
	
func move_outer_blue_fist_stack():
	for i in range(2):
		party[outer_blue[i]].move_to(DPos.OUTER_BLUE_ADJUST_POS[i].rotated(rotation))

func move_after_fist_bait():
	var keys = outer_green + inner_green + outer_blue
	var is_clockwise_reorder = [is_clockwise[2], is_clockwise[3], is_clockwise[1], is_clockwise[4], is_clockwise[0], is_clockwise[5]]
	
	for i in range(6):
		if is_clockwise_reorder[i]:
			party[keys[i]].move_to(DPos.CLOCKWISE_HAND_POS[i].rotated(rotation))
		else:
			party[keys[i]].move_to(DPos.ANTICLOCKWISE_HAND_POS[i].rotated(rotation))
	
	for i in range(2):
		party[inner_blue[i]].move_to(DPos.INNER_BLUE_POP_POS[i].rotated(rotation))
		
func move_beyond_bait():
	for i in range(2):
		party[inner_blue[i]].move_to(DPos.INNER_BLUE_BEYOND_BAIT_POS[i].rotated(rotation))

func move_green_wait():
	var keys = outer_green + inner_green
	for i in range(4):
		party[keys[i]].move_to(DPos.GREEN_WAIT_POS[i].rotated(rotation))
		
func move_green_monitors():
	var keys = outer_green + inner_green
	for i in range(4):
		party[keys[i]].move_to(DPos.GREEN_MONITOR_POS[i].rotated(rotation))

func move_pile_pitch_stack():
	var stack_keys = outer_blue + inner_blue
	for key in stack_keys:
		party[key].set_sprint()
	stack_keys.erase(beyond_defense_key)
		
	for i in range(stack_keys.size()):
		if left_omega_monitor:
			if stack_keys[i] == monitor_key:
				party[stack_keys[i]].move_to(DPos.MONITOR_STACK_NORTH.rotated(rotation))
			else:
				party[stack_keys[i]].move_to(DPos.PILE_PITCH_STACK_NORTH.rotated(rotation))
		else:
			if stack_keys[i] == monitor_key:
				party[stack_keys[i]].move_to(DPos.MONITOR_STACK_SOUTH.rotated(rotation))
			else:
				party[stack_keys[i]].move_to(DPos.PILE_PITCH_STACK_SOUTH.rotated(rotation))
	
	if beyond_defense_key == monitor_key:
		if left_omega_monitor:
			party[beyond_defense_key].move_to(DPos.MONITOR_AWAY_NORTH.rotated(rotation))
		else:
			party[beyond_defense_key].move_to(DPos.MONITOR_AWAY_SOUTH.rotated(rotation))

	else:
		if left_omega_monitor:
			party[beyond_defense_key].move_to(DPos.NOTHING_AWAY_NORTH.rotated(rotation))
		else:
			party[beyond_defense_key].move_to(DPos.NOTHING_AWAY_SOUTH.rotated(rotation))

func adjust_monitor():
	
	if monitor_key == player_key and !Global.spectate_mode:
		return
	
	if left_omega_monitor:
		if left_player_monitor:
			party[monitor_key].look_at_direction(party[monitor_key].global_position + Vector3(0, 0, 1).rotated(Vector3.UP, -rotation))
		else:
			party[monitor_key].look_at_direction(party[monitor_key].global_position + Vector3(0, 0, -1).rotated(Vector3.UP, -rotation))
	
	else:
		if left_player_monitor:
			party[monitor_key].look_at_direction(party[monitor_key].global_position + Vector3(0, 0, -1).rotated(Vector3.UP, -rotation))
		else:
			party[monitor_key].look_at_direction(party[monitor_key].global_position + Vector3(0, 0, 1).rotated(Vector3.UP, -rotation))
	
func move_hello_world():
	if starboard:
		party[near_key].move_to(DPos.HELLO_WORLD_NORTH_POS["near"].rotated(rotation))
		party[far_key].move_to(DPos.HELLO_WORLD_NORTH_POS["far"].rotated(rotation))
		for i in range(blue_nothings_keys.size()):
			party[blue_nothings_keys[i]].move_to(DPos.HELLO_WORLD_NORTH_POS["blue_nothing"].rotated(rotation))
		party[outer_green[0]].move_to(DPos.HELLO_WORLD_NORTH_POS["outer_green_north"].rotated(rotation))
		party[outer_green[1]].move_to(DPos.HELLO_WORLD_NORTH_POS["outer_green_south"].rotated(rotation))
		party[inner_green[0]].move_to(DPos.HELLO_WORLD_NORTH_POS["inner_green_north"].rotated(rotation))
		party[inner_green[1]].move_to(DPos.HELLO_WORLD_NORTH_POS["inner_green_south"].rotated(rotation))
	else:
		party[near_key].move_to(DPos.HELLO_WORLD_SOUTH_POS["near"].rotated(rotation))
		party[far_key].move_to(DPos.HELLO_WORLD_SOUTH_POS["far"].rotated(rotation))
		for i in range(blue_nothings_keys.size()):
			party[blue_nothings_keys[i]].move_to(DPos.HELLO_WORLD_SOUTH_POS["blue_nothing"].rotated(rotation))
		party[outer_green[0]].move_to(DPos.HELLO_WORLD_SOUTH_POS["outer_green_north"].rotated(rotation))
		party[outer_green[1]].move_to(DPos.HELLO_WORLD_SOUTH_POS["outer_green_south"].rotated(rotation))
		party[inner_green[0]].move_to(DPos.HELLO_WORLD_SOUTH_POS["inner_green_north"].rotated(rotation))
		party[inner_green[1]].move_to(DPos.HELLO_WORLD_SOUTH_POS["inner_green_south"].rotated(rotation))
		
func pop_first_green():
	if starboard:
		party[inner_green[1]].move_to(DPos.GREEN_FIRST_POP_NORTH.rotated(rotation))
	else:
		party[inner_green[0]].move_to(DPos.GREEN_FIRST_POP_SOUTH.rotated(rotation))

func show_omega_m_and_hitbox():
	omega_m_gold.play_start_sword()
	omega_m_gold.global_rotation = Vector3(0, PI/2, 0)
	omega_m_gold.visible = true
	var hitboxring = HITBOX_RING.instantiate()
	get_tree().current_scene.add_child(hitboxring)
	hitboxring.visible = false
	hitboxring.scale = 1.35 * Vector3(1, 1, 1)
	hitboxring.global_position = Vector3(0.414, 0, 0)
	await get_tree().create_timer(3.80).timeout
	hitboxring.visible = true
		
func move_before_second_green():
	var keys = inner_green + outer_blue + inner_blue
	for key in keys:
		if key == "t2":
			party[key].move_to(DPos.GREEN_WAIT_SECOND_POS["tank"].rotated(rotation))
		else:
			party[key].move_to(DPos.GREEN_WAIT_SECOND_POS["party"].rotated(rotation))
	if starboard:
		party[outer_green[0]].move_to(DPos.GREEN_WAIT_SECOND_POS["east"].rotated(rotation))
		party[outer_green[1]].move_to(DPos.GREEN_WAIT_SECOND_POS["west"].rotated(rotation))
	else:
		party[outer_green[0]].move_to(DPos.GREEN_WAIT_SECOND_POS["west"].rotated(rotation))
		party[outer_green[1]].move_to(DPos.GREEN_WAIT_SECOND_POS["east"].rotated(rotation))
		
func move_pop_second_green():
	if starboard:
		party[outer_green[0]].move_to(DPos.GREEN_SECOND_POP["east"].rotated(rotation))
		party[outer_green[1]].move_to(DPos.GREEN_SECOND_POP["west"].rotated(rotation))
	else:
		party[outer_green[0]].move_to(DPos.GREEN_SECOND_POP["west"].rotated(rotation))
		party[outer_green[1]].move_to(DPos.GREEN_SECOND_POP["east"].rotated(rotation))
	
	
