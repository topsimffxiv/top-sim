extends Node

# Controllers
@onready var hello_world_anim: AnimationPlayer = %HelloWorldAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var chains_controller: ChainsController = %ChainsController
@onready var fail_list: FailList = %FailList

# debuff icon preloads
const CRITICAL_PERFORMANCE_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/critical_performance_bug.tscn")
const CRITICAL_UNDERFLOW_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/critical_underflow_bug.tscn")
const PERFORMANCE_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/p3/performance_code_smell.tscn")
const PERFORMANCE_DEBUGGER = preload("res://scenes/ui/auras/debuff_icons/p3/performance_debugger.tscn")
const UNDERFLOW_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/p3/underflow_code_smell.tscn")
const UNDERFLOW_DEBUGGER = preload("res://scenes/ui/auras/debuff_icons/p3/underflow_debugger.tscn")
const LOCAL_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/common/local_code_smell.tscn")
const LOCAL_REGRESSION = preload("res://scenes/ui/auras/debuff_icons/common/local_regression.tscn")
const REMOTE_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/common/remote_code_smell.tscn")
const REMOTE_REGRESSION = preload("res://scenes/ui/auras/debuff_icons/common/remote_regression.tscn")
const LATENT_DEFECT = preload("res://scenes/ui/auras/debuff_icons/p3/latent_defect.tscn")
const OVERFLOW_DEBUGGER = preload("res://scenes/ui/auras/debuff_icons/p3/overflow_debugger.tscn")
const SYNCHRONIZATION_DEBUGGER = preload("res://scenes/ui/auras/debuff_icons/p3/synchronization_debugger.tscn")
const CRITICAL_OVERFLOW_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/critical_overflow_bug.tscn")
const CRITICAL_SYNCHRONIZATION_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/critical_synchronization_bug.tscn")
const OVERFLOW_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/p3/overflow_code_smell.tscn")
const SYNCHRONIZATION_CODE_SMELL = preload("res://scenes/ui/auras/debuff_icons/p3/synchronization_code_smell.tscn")
const LATENT_SYNCHRONIZATION_BUG = preload("res://scenes/ui/auras/debuff_icons/p3/latent_synchronization_bug.tscn")
const LATENT_PERFORMANCE_DEFECT = preload("res://scenes/ui/auras/debuff_icons/p3/latent_performance_defect.tscn")
const CASCADING_LATENT_DEFECT = preload("res://scenes/ui/auras/debuff_icons/p3/cascading_latent_defect.tscn")
const MAGIC_VULN = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")


var party: Dictionary
var blue_is_defamation: bool
var n_tot: int = 0
var n_delta: int # used to flag whether left/right roles need to swap when going to tower
var left_party: Array # keeps track of the left side members
var right_party: Array # keeps track of the right side members

var mx_stack = Mutex.new() # for stack_owner
var mx_defam = Mutex.new()
var stack_owner: Array # array players currently with a stack debuff
var defam_owner: Array # array playaers currently with a defam debuff
var towers: Array # list of active towers

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle", "donut", "red_rot_tower", "blue_rot_tower"])
	lockon_controller.pre_load(["Critical_Performance_Bug", "Critical_Underflow_Bug"])
	chains_controller.pre_load(["local_code_smell", "remote_code_smell", "local_regression", "remote_regression"])
	chains_controller.patch_activated.connect(on_patch_activated)
	instantiate_party(new_party)
	hello_world_anim.play("hello_world")

func instantiate_party(new_party):
	party = new_party
	for key in party:
		party[key].global_position = HWPos.STARTING_POSITIONS[key]
	blue_is_defamation = randf() > 0.5
	if Global.p3_blue_is_defamation:
		blue_is_defamation = true
	if Global.p3_red_is_defamation:
		blue_is_defamation = false
	
	var player_key
	
	var party_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	for key in party_keys:
		if party[key].is_player():
			player_key = key
	
	randomize()
	party_keys.shuffle()
	
	if Global.p3_start_defam:
		var player_idx = party_keys.find(player_key)
		if player_idx != 0 and player_idx != 1:
			var swap_idx = randi_range(0, 1) + 0
			var tmp = party_keys[swap_idx]
			party_keys[swap_idx] = party_keys[player_idx]
			party_keys[player_idx] = tmp
	elif Global.p3_start_remote:
		var player_idx = party_keys.find(player_key)
		if player_idx != 2 and player_idx != 3:
			var swap_idx = randi_range(0, 1) + 2
			var tmp = party_keys[swap_idx]
			party_keys[swap_idx] = party_keys[player_idx]
			party_keys[player_idx] = tmp
	elif Global.p3_start_stack:
		var player_idx = party_keys.find(player_key)
		if player_idx != 4 and player_idx != 5:
			var swap_idx = randi_range(0, 1) + 4
			var tmp = party_keys[swap_idx]
			party_keys[swap_idx] = party_keys[player_idx]
			party_keys[player_idx] = tmp
	elif Global.p3_start_local:
		var player_idx = party_keys.find(player_key)
		if player_idx != 6 and player_idx != 7:
			var swap_idx = randi_range(0, 1) + 6
			var tmp = party_keys[swap_idx]
			party_keys[swap_idx] = party_keys[player_idx]
			party_keys[player_idx] = tmp

	left_party = party_keys.slice(0, 8, 2)
	right_party = party_keys.slice(1, 8, 2)

func cast_hello_world() -> void:
	cast_bar.cast("Hello World", 4.6)
	
func hw_cast_end() -> void:
	# spawn local and remote smells
	for i in range(0,4):
		spawn_local_code_smell(party[left_party[i]], party[right_party[i]], 86.0 - 21*i)
		spawn_remote_code_smell(party[left_party[i]], party[right_party[i]], 86.0 - 21*((i+2)%4))
		spawn_latent_synchronization_bug(party[left_party[i]])
		spawn_latent_synchronization_bug(party[right_party[i]])
		if i == 0:	
			spawn_overflow_code_smell(party[left_party[i]])
			spawn_overflow_code_smell(party[right_party[i]])
			if blue_is_defamation:
				spawn_performance_smell(party[left_party[i]])
				spawn_performance_smell(party[right_party[i]])
			else:
				spawn_underflow_smell(party[left_party[i]])
				spawn_underflow_smell(party[right_party[i]])
		if i == 2:
			spawn_synchronization_code_smell(party[left_party[i]])
			spawn_synchronization_code_smell(party[right_party[i]])
			if blue_is_defamation:
				spawn_underflow_smell(party[left_party[i]])
				spawn_underflow_smell(party[right_party[i]])
			else:
				spawn_performance_smell(party[left_party[i]])
				spawn_performance_smell(party[right_party[i]])
		if i == 3:
			spawn_latent_defect(party[left_party[i]])
			spawn_latent_defect(party[right_party[i]])

func fix_parties() -> void:
	# check positions of each pair and set them to the correct light party
	for i in range(0,4):
		if i == 0 or i == 3:
			var l_pc = party[left_party[i]]
			var r_pc = party[right_party[i]]
			var left_y = l_pc.get_pos().y # east/west
			var left_x= l_pc.get_pos().x
			var right_y = r_pc.get_pos().y
			var right_x = r_pc.get_pos().x
			if right_y > left_y and abs(right_y-left_y) > 0.1: # if "right" defam further east, swap
				var tmp = left_party[i]
				left_party[i] = right_party[i]
				right_party[i] = tmp
			elif abs(right_y-left_y) < 0.1:
				if left_y < 0:
					if right_x > left_x: # if left half and right above left, swap
						var tmp = left_party[i]
						left_party[i] = right_party[i]
						right_party[i] = tmp
				else:
					if left_x > right_x: # right half and left above right, swap
						var tmp = left_party[i]
						left_party[i] = right_party[i]
						right_party[i] = tmp
		else:
			var l_pc = party[left_party[i]]
			var r_pc = party[right_party[i]]
			var left_y = l_pc.get_pos().y # east/west
			var left_x= l_pc.get_pos().x
			var right_y = r_pc.get_pos().y
			var right_x = r_pc.get_pos().x
			if right_y < left_y and abs(right_y-left_y) > 0.1: # if "right" stack further west, swap
				var tmp = left_party[i]
				left_party[i] = right_party[i]
				right_party[i] = tmp
			elif abs(right_y-left_y) < 0.1:
				if left_y < 0:
					if right_x < left_x: # if left half and right below left, swap
						var tmp = left_party[i]
						left_party[i] = right_party[i]
						right_party[i] = tmp
				else:
					if left_x < right_x: # right half and left below right, swap
						var tmp = left_party[i]
						left_party[i] = right_party[i]
						right_party[i] = tmp

func move_to_path_radius() -> void:
	for i in range(0,4):
		var l_pc = party[left_party[i]]
		var r_pc = party[right_party[i]]
		if i % 2 == 1:
			l_pc.move_to(HWPos.TETHER_PATH_RADIUS * l_pc.get_pos().normalized())
			r_pc.move_to(HWPos.TETHER_PATH_RADIUS * r_pc.get_pos().normalized())
		if i == 0:
			l_pc.move_to(HWPos.DEFAMATION_PATH_RADIUS * l_pc.get_pos().normalized())
			r_pc.move_to(HWPos.DEFAMATION_PATH_RADIUS * r_pc.get_pos().normalized())
		if i == 2:
			l_pc.move_to(HWPos.STACK_PATH_RADIUS * l_pc.get_pos().normalized())
			r_pc.move_to(HWPos.STACK_PATH_RADIUS * r_pc.get_pos().normalized())

func move_to_initial_pos() -> void:
	move_rot_to_soak_pos()
	move_tether_to_wait_pos()

func move_rot_to_soak_pos() -> void:
	for i in [0, 2]:
		party[left_party[i]].rotate_to(HWPos.LEFT_SOAK_POS[i].rotated(n_tot%8 * PI/4))
		party[right_party[i]].rotate_to(HWPos.RIGHT_SOAK_POS[i].rotated(n_tot%8 * PI/4))	

func move_tether_to_wait_pos() -> void:
	for i in [1, 3]:
		var left_wait_pos = HWPos.TETHER_PATH_RADIUS * (HWPos.LEFT_SOAK_POS[i].rotated(n_tot%8 * PI/4)).normalized()
		var right_wait_pos = HWPos.TETHER_PATH_RADIUS * (HWPos.RIGHT_SOAK_POS[i].rotated(n_tot%8 * PI/4)).normalized()
		party[left_party[i]].move_to(left_wait_pos)
		party[right_party[i]].move_to(right_wait_pos)
		
func move_tether_to_soak_pos() -> void:
	for i in [1, 3]:
		party[left_party[i]].move_to(HWPos.LEFT_SOAK_POS[i].rotated(n_tot%8 * PI/4))
		party[right_party[i]].move_to(HWPos.RIGHT_SOAK_POS[i].rotated(n_tot%8 * PI/4))
			
func move_to_pass_rots() -> void:
	for i in [1, 3]:
		party[left_party[i]].move_to(party[left_party[(i+1)%4]].get_pos())
		party[right_party[i]].move_to(party[right_party[(i+1)%4]].get_pos())

func move_party_to_dodge_pos() -> void:
	for i in range(0,4):
		party[left_party[i]].move_to(HWPos.LEFT_DODGE_POS[i].rotated(n_tot%8 * PI/4))
		party[right_party[i]].move_to(HWPos.RIGHT_DODGE_POS[i].rotated(n_tot%8 * PI/4))

func move_party_prep_pos() -> void:
	for i in range(0,4):
		var l_pc = party[left_party[i]]
		var r_pc = party[right_party[i]]
		if i % 2 == 0:
			l_pc.move_to(HWPos.TETHER_PATH_RADIUS * l_pc.get_pos().normalized())
			r_pc.move_to(HWPos.TETHER_PATH_RADIUS * r_pc.get_pos().normalized())
		if i == 1:
			l_pc.move_to(HWPos.STACK_PATH_RADIUS * l_pc.get_pos().normalized())
			r_pc.move_to(HWPos.STACK_PATH_RADIUS * r_pc.get_pos().normalized())
		if i == 3:
			l_pc.move_to(HWPos.DEFAMATION_PATH_RADIUS * l_pc.get_pos().normalized())
			r_pc.move_to(HWPos.DEFAMATION_PATH_RADIUS * r_pc.get_pos().normalized())

func adjust_to_next_role() -> void:
	#var local = left_party.pop_back()
	#left_party.push_front(local)
	left_party.push_front(left_party.pop_back())
	right_party.push_front(right_party.pop_back())
	
func move_tether_to_wait_pos_final() -> void:
	for i in [1, 3]:
		var left_wait_pos = HWPos.TETHER_PATH_RADIUS * (HWPos.LEFT_SOAK_POS[1].rotated(n_tot%8 * PI/4)).normalized()
		var right_wait_pos = HWPos.TETHER_PATH_RADIUS * (HWPos.RIGHT_SOAK_POS[1].rotated(n_tot%8 * PI/4)).normalized()
		party[left_party[i]].move_to(left_wait_pos)
		party[right_party[i]].move_to(right_wait_pos)

func move_tether_to_soak_pos_final() -> void:
	for i in [1, 3]:
		party[left_party[i]].move_to(HWPos.LEFT_SOAK_POS[1].rotated(n_tot%8 * PI/4))
		party[right_party[i]].move_to(HWPos.RIGHT_SOAK_POS[1].rotated(n_tot%8 * PI/4))

func move_party_to_dodge_pos_final() -> void:
	for i in range(0, 4):
		if i % 2 == 0:
			continue
		else:
			party[left_party[i]].move_to(HWPos.LEFT_FINAL_POS[i].rotated(n_tot%8 * PI/4))
			party[right_party[i]].move_to(HWPos.RIGHT_FINAL_POS[i].rotated(n_tot%8 * PI/4))

func cast_critical_error() -> void:
	cast_bar.cast("Critical Error", 7.5)
	await get_tree().create_timer(7.5).timeout
	for key in party:
		var pc = party[key]
		if !pc.has_debuff("Overflow Debugger"):
			fail_list.add_fail("Missing Overflow Debugger: %s" % pc.name)

func cast_latent_defect() -> void:
	# if tower can spawn same spot, change to randi_range(0,7)
	n_delta = randi_range(1,7) # new n to add to the tally n_tot, n_tot mod 8 * PI/2 is tower and coord rotation
	print("n_delta is %s" % n_delta)
	if n_delta == 1 or n_delta == 7:
		swap_tether_sides()
	if n_delta >= 3 and n_delta <= 5:
		swap_rot_sides()
	n_tot += n_delta
	print("n_tot is %s" % n_delta)
	
	var rand_angle = (n_tot % 8) * PI/4 # using mod 8 to avoid potential numerical error drift from large angles
	print("(n_tot mod 8) * PI/4 is %s" % rad_to_deg(rand_angle))
	var tower_rotation
	if blue_is_defamation:
		tower_rotation = (n_tot % 8) * PI/4
	else:
		tower_rotation = (n_tot % 8) * PI/4 + PI
	print(rad_to_deg(tower_rotation))
	spawn_tower_set(tower_rotation)
	cast_bar.cast("Latent Defect", 9.3)
	
	print("add final omega animation stuff")
	
func latent_defect_cast_end() -> void:
	await get_tree().create_timer(0.2).timeout
	for tower in towers.slice(0, 2):
		var pos = Vector2(tower.global_position.x, tower.global_position.z)
		var latent = ground_aoe_controller.spawn_circle(pos, 15.0, 0.3, Color.AQUA, [1, 1, "Latent Performance Defect"], false)
		latent.collisions_checked.connect(_on_latent_collision)
		tower.visible = false
	for tower in towers.slice(2):
		var pos = Vector2(tower.global_position.x, tower.global_position.z)
		var cascading = ground_aoe_controller.spawn_circle(pos, 15.0, 0.3, Color.PINK, [1, 1, "Cascading Latent Defect"], false)
		cascading.collisions_checked.connect(_on_cascading_collision)
		tower.visible = false
	for tower in towers:
		tower.queue_free()
	towers = []
	
func _on_latent_collision(bodies: Array):
	for body in bodies:
		var sig = body.add_debuff(LATENT_PERFORMANCE_DEFECT, 10.0, false, "Latent Performance Defect")
		sig.connect(_on_latent_performance_defect_timeout)

func _on_latent_performance_defect_timeout(owner_key):
	fail_list.add_fail("Failed to cleanse Latent Performance Defect: %s" % party[owner_key].name)
	
func _on_cascading_collision(bodies: Array):
	for body in bodies:
		var sig = body.add_debuff(CASCADING_LATENT_DEFECT, 10.0, false, "Cascading Latent Defect")
		sig.connect(_on_cascading_latent_defect_timeout)
		
func _on_cascading_latent_defect_timeout(owner_key):
	fail_list.add_fail("Failed to cleanse Cascading Latent Defect: %s" % party[owner_key].name)

func _on_pass_blue_rot(target: Node3D):
	if target.has_debuff("Critical Performance Bug"):
		return
	if target.has_debuff("Performance Debugger"):
		return
	spawn_performance_bug(target)
	
func _on_pass_red_rot(target: Node3D):
	if target.has_debuff("Critical Underflow Bug"):
		return
	if target.has_debuff("Underflow Debugger"):
		return
	spawn_underflow_bug(target)
	
func spawn_performance_smell(target: Node3D):
	var timeout = target.add_debuff(PERFORMANCE_CODE_SMELL, 3.0, false, "Performance Code Smell")
	timeout.connect(performance_code_smell_timeout)
	spawn_performance_bug(target)
	
func spawn_performance_bug(target: Node3D):
	var arr = lockon_controller.add_marker_rot("Critical_Performance_Bug", target)
	var new_rot = arr[0]
	var rot_timeout = arr[1]
	new_rot.pass_blue_rot.connect(_on_pass_blue_rot)
	new_rot.rot_overlap.connect(_on_rot_overlap)
	if target.has_debuff("Performance Code Smell"):
		return
	rot_timeout.connect(critical_performance_bug_timeout)
	
func spawn_underflow_smell(target: Node3D):
	var timeout = target.add_debuff(UNDERFLOW_CODE_SMELL, 3.0, false, "Underflow Code Smell")
	timeout.connect(underflow_code_smell_timeout)
	spawn_underflow_bug(target)
	
func spawn_underflow_bug(target: Node3D):
	var arr = lockon_controller.add_marker_rot("Critical_Underflow_Bug", target)
	var new_rot = arr[0]
	var rot_timeout = arr[1]
	new_rot.pass_red_rot.connect(_on_pass_red_rot)
	new_rot.rot_overlap.connect(_on_rot_overlap)
	if target.has_debuff("Underflow Code Smell"):
		return
	rot_timeout.connect(critical_underflow_bug_timeout)
	
func _on_rot_overlap(source, target):
	# 3rd and 4th set of rots will be immune to the other because they had the other on the 1st or 2nd set
	# This means if both parties have opposite debuggers  and both have rots, they will be immune to each other
	if source.has_debuff("Performance Debugger") and target.has_debuff("Underflow Debugger"):
		return
	if source.has_debuff("Underflow Debugger") and target.has_debuff("Performance Debugger"):
		return
	#if rots overlap on the first or second set, notify - wipe condition always
	fail_list.add_fail("Rot overlap: %s and %s" % [source.get_name(), target.get_name()])
	
func spawn_remote_regression(source: Node3D, target: Node3D, duration: float) -> RemoteRegression:
	var chain = chains_controller.spawn_remote_regression(source, target)
	var source_signal = source.add_debuff(REMOTE_REGRESSION, duration, false, "Remote Regression")
	var target_signal = target.add_debuff(REMOTE_REGRESSION, duration, false, "Remote Regression")
	source_signal.connect(remote_regression_timeout)
	target_signal.connect(remote_regression_timeout)
	return chain
	
func spawn_local_regression(source: Node3D, target: Node3D, duration: float) -> LocalRegression:
	var chain = chains_controller.spawn_local_regression(source, target)
	var source_signal = source.add_debuff(LOCAL_REGRESSION, duration, false, "Local Regression")
	var target_signal = target.add_debuff(LOCAL_REGRESSION, duration, false, "Local Regression")
	source_signal.connect(local_regression_timeout)
	target_signal.connect(local_regression_timeout)
	return chain
	
func spawn_remote_code_smell(source: Node3D, target: Node3D, duration: float) -> RemoteCodeSmell:
	var chain = chains_controller.spawn_remote_code_smell(source, target, duration)
	var source_signal = source.add_debuff(REMOTE_CODE_SMELL, duration, false, "Remote Code Smell")
	var target_signal = target.add_debuff(REMOTE_CODE_SMELL, duration, false, "Remote Code Smell")
	source_signal.connect(remote_code_smell_timeout)
	target_signal.connect(remote_code_smell_timeout)
	source.get_debuff("Remote Code Smell").remote_code_smell_toggle_visible.connect(on_remote_code_smell_toggle_visible)
	target.get_debuff("Remote Code Smell").remote_code_smell_toggle_visible.connect(on_remote_code_smell_toggle_visible)
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

func spawn_overflow_code_smell(target: Node3D):
	var timeout = target.add_debuff(OVERFLOW_CODE_SMELL, 3.0, false, "Overflow Code Smell")
	timeout.connect(overflow_code_smell_timeout)

func spawn_synchronization_code_smell(target: Node3D):
	var timeout = target.add_debuff(SYNCHRONIZATION_CODE_SMELL, 3.0, false, "Synchronization Code Smell")
	timeout.connect(synchronization_code_smell_timeout)

func spawn_overflow_bug(target: Node3D):
	var timeout = target.add_debuff(CRITICAL_OVERFLOW_BUG, 21.0, false, "Critical Overflow Bug")
	timeout.connect(critical_overflow_bug_timeout)
	mx_defam.lock()
	defam_owner.append(target)
	mx_defam.unlock()
	
func spawn_synchronization_bug(target: Node3D):
	var timeout = target.add_debuff(CRITICAL_SYNCHRONIZATION_BUG, 21.0, false, "Critical Synchronization Bug")
	timeout.connect(critical_synchronization_bug_timeout)
	mx_stack.lock()
	stack_owner.append(target)
	mx_stack.unlock()

func spawn_latent_synchronization_bug(target: Node3D):
	var sig = target.add_debuff(LATENT_SYNCHRONIZATION_BUG, 69.0, false, "Latent Synchronization Bug")
	sig.connect(_on_latent_synchronization_bug_timeout)

func spawn_latent_defect(target: Node3D):
	var sig = target.add_debuff(LATENT_DEFECT, 27.0, false, "Latent Defect")
	sig.connect(_on_latent_defect_timeout)
	
func on_patch_activated(target: Node3D, source: Node3D) -> void:
	var players = []
	for key in party:
		players.append(party[key])
	ground_aoe_controller.spawn_circle(Vector2(target.global_position.x, target.global_position.z), 7.0, 0.3,\
		Color.IVORY, [0, 0, "Patch", players])
	ground_aoe_controller.spawn_circle(Vector2(source.global_position.x, source.global_position.z), 7.0, 0.3,\
		Color.IVORY, [0, 0, "Patch", players])
		
func remote_regression_timeout(owner_key: String) -> void:
	fail_list.add_fail("Remote Regression expired: %s" % party[owner_key].get_name())

func local_regression_timeout(owner_key: String) -> void:
	fail_list.add_fail("Local Regression expired: %s" % party[owner_key].get_name())
	
func remote_code_smell_timeout(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("RemoteCodeSmellMesh")
	if !chain:
		return
	
	spawn_remote_regression(chain.source, chain.target, 10.0)
	chains_controller.remove_chain(chain)
	
func local_code_smell_timeout(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("LocalCodeSmellMesh")
	if !chain:
		return
	spawn_local_regression(chain.source, chain.target, 10.0)
	chains_controller.remove_chain(chain)
	return
	
func performance_code_smell_timeout(owner_key) -> void:
	var pc = party[owner_key]
	var timeout = pc.add_debuff(CRITICAL_PERFORMANCE_BUG, 27.0, false, "Critical Performance Bug")
	var bug = pc.get_node("Lockon").get_node_or_null("Critical_Performance_Bug")
	if !bug:
		print("bug not found")
	bug.armed = true
	timeout.connect(critical_performance_bug_timeout)
	
func underflow_code_smell_timeout(owner_key) -> void:
	var pc = party[owner_key]
	var timeout = pc.add_debuff(CRITICAL_UNDERFLOW_BUG, 27.0, false, "Critical Underflow Bug")
	var bug = pc.get_node("Lockon").get_node_or_null("Critical_Underflow_Bug")
	if !bug:
		print("bug not found")
	bug.armed = true
	timeout.connect(critical_underflow_bug_timeout)	
	
func critical_performance_bug_timeout(owner_key) -> void:
	var pc = party[owner_key]
	pc.add_debuff(PERFORMANCE_DEBUGGER, 10000.0, false, "Performance Debugger")
	lockon_controller.remove_marker("Critical_Performance_Bug", pc)
	ground_aoe_controller.spawn_circle(Vector2(pc.global_position.x, pc.global_position.z), HWPos.ROT_RADIUS, 0.3, \
		Color.CORNFLOWER_BLUE, [0, 0, "Critical Performance Bug", [party[owner_key]]], false)
	pc.remove_debuff("Latent Performance Defect")
			
func critical_underflow_bug_timeout(owner_key) -> void:
	var pc = party[owner_key]
	pc.add_debuff(UNDERFLOW_DEBUGGER, 10000.0, false, "Underflow Debugger")
	lockon_controller.remove_marker("Critical_Underflow_Bug", pc)
	ground_aoe_controller.spawn_circle(Vector2(pc.global_position.x, pc.global_position.z), HWPos.ROT_RADIUS, 0.3, \
		Color.INDIAN_RED, [0, 0, "Critical Underflow Bug", [party[owner_key]]], false)
	pc.remove_debuff("Cascading Latent Defect")

func overflow_code_smell_timeout(owner_key) -> void:
	spawn_overflow_bug(party[owner_key])
	
func critical_overflow_bug_timeout(owner_key) -> void:
	var pc = party[owner_key]
	pc.add_debuff(OVERFLOW_DEBUGGER, 10000.0, false, "Overflow Debugger")
	var defam = ground_aoe_controller.spawn_circle(Vector2(pc.global_position.x, pc.global_position.z), HWPos.DEFAMATION_RADIUS,\
		 0.3, Color.WEB_PURPLE, [1, 2, "Critical Overflow Bug"], false)
	defam.collisions_checked.connect(_on_overflow_bug_collision)

func _on_overflow_bug_collision(bodies: Array) -> void:
	for body in bodies:
		body.add_debuff(MAGIC_VULN, 1.0, false, "Magic Vulnerability Up")
		body.remove_debuff("Latent Defect")
		if body in defam_owner:
			mx_defam.lock()
			defam_owner.erase(body)
			mx_defam.unlock()
			continue
			
		if body.has_debuff("Overflow Debugger"):
			body.remove_debuff("Overflow Debugger")
		else:
			spawn_overflow_bug(body)	

func synchronization_code_smell_timeout(owner_key) -> void:
	spawn_synchronization_bug(party[owner_key])
			
func critical_synchronization_bug_timeout(owner_key) -> void:
	
	var pc = party[owner_key]
	pc.add_debuff(SYNCHRONIZATION_DEBUGGER, 10000.0, false, "Synchronization Debugger")
	var stack = ground_aoe_controller.spawn_circle(pc.get_pos(), HWPos.STACK_RADIUS,\
		0.3, Color.REBECCA_PURPLE, [2, 3, "Critical Synchronization Bug"], false)
	stack.collisions_checked.connect(_on_sync_bug_collision)

func _on_sync_bug_collision(bodies: Array):
	for body in bodies:
		body.add_debuff(MAGIC_VULN, 1.0, false, "Magic Vulnerability Up")
		body.remove_debuff("Latent Synchronization Bug")
		body.add_debuff(MAGIC_VULN)
		if body in stack_owner:
			mx_stack.lock()
			stack_owner.erase(body)
			mx_stack.unlock()
			continue
			
		if body.has_debuff("Synchronization Debugger"):
			body.remove_debuff("Synchronization Debugger")
		else:
			spawn_synchronization_bug(body)		

func _on_latent_synchronization_bug_timeout(owner_key):
	fail_list.add_fail("Latent Synchronization Bug not cleansed (stack missed): %s" % party[owner_key].name)

func _on_latent_defect_timeout(owner_key):
	fail_list.add_fail("Latent Defect not cleansed (missed defamation): %s" % party[owner_key].name)
		
func on_remote_code_smell_toggle_visible(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("RemoteCodeSmellMesh")
	if !chain:
		return
	chain.visible = true
	
func on_local_code_smell_toggle_visible(owner_key) -> void:
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("LocalCodeSmellMesh")
	if !chain:
		return
	chain.visible = true

func spawn_tower_set(rotation: float):
	var tower1 = ground_aoe_controller.spawn_blue_rot_tower(rotation + PI/4)
	var tower2 = ground_aoe_controller.spawn_blue_rot_tower(rotation - PI/4)	
	var tower3 = ground_aoe_controller.spawn_red_rot_tower(rotation + PI + PI/4)
	var tower4 = ground_aoe_controller.spawn_red_rot_tower(rotation + PI - PI/4)
	towers = [tower1, tower2, tower3, tower4]

func swap_party_sides():
	var temp = left_party
	left_party = right_party
	right_party = temp

func swap_rot_sides():
	for i in [0, 2]:
		var tmp = left_party[i]
		left_party[i] = right_party[i]
		right_party[i] = tmp
		
func swap_tether_sides():
	for i in [1, 3]:
		var tmp = left_party[i]
		left_party[i] = right_party[i]
		right_party[i] = tmp
