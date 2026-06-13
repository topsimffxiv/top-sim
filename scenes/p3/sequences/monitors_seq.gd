extends Node

const LEFT_LARGE_WAVE_CANNON = preload("res://scenes/p3/lockon/left_monitor.tscn")
const RIGHT_LARGE_WAVE_CANNON = preload("res://scenes/p3/lockon/right_monitor.tscn")

const OVERSAMPLED_WAVE_CANNON_LOADING = preload("res://scenes/ui/auras/debuff_icons/common/oversampled_wave_cannon_loading.tscn")
const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const THRICE_COME_RUIN = preload("res://scenes/ui/auras/debuff_icons/common/thrice_come_ruin.tscn")

@onready var monitors_anim: AnimationPlayer = %MonitorsAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var fail_list: FailList = %FailList
@onready var final_omega: Node3D = %Final_Omega

var party
var monitors = []
var monitors_keys = []
var nothings_keys = []
var is_left = [randf()>0.5, randf()>0.5, randf()>0.5, randf()> 0.5]

const MONITOR_RADIUS = 16.0
const OMEGA_MONITOR_SCALE = 3.5


func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle"])
	lockon_controller.pre_load(["Left_Oversampled_Wave_Cannon", "Right_Oversampled_Wave_Cannon", \
		"Target_1", "Target_2", "Target_3", "Target_4", "Target_5", "Link_1", "Link_2", "Link_3"])
	instantiate_party(new_party)
	monitors_anim.play("monitors")

	
func instantiate_party(new_party: Dictionary):
	# initial positions
	party = new_party
	var conga_width = 42.0
	var conga = ["h1", "r1", "m1", "t1", "t2", "m2", "r2", "h2"]
	var k = 0.0
	for elem: String in conga:
		party[elem].global_position = Vector3(-conga_width * (-0.5 + k/7.0), 0, -17)
		k += 1.0
	
	# set up monitors and nothings
	randomize()
	nothings_keys = ["h1", "r1", "m1", "t1", "t2", "m2", "r2", "h2"]
	var potential_monitors_idxs = [0, 1, 2, 3, 4, 5, 6, 7]
	var player_key
	var player_idx
	var monitor_keys_to_add = 3
	var monitors_keys_idxs = [] # indices of keys that are monitors
	
	if Global.p3_force_monitor or Global.p3_force_nothing: # remove player from potential random monitor list regardless
		for key in nothings_keys: # find player key
			if party[key].is_player():
				player_key = key
		player_idx = nothings_keys.find(player_key)
		potential_monitors_idxs.erase(player_idx)
		if Global.p3_force_monitor: # if player wants monitor, put them in monitor list
			monitor_keys_to_add = 2
			monitors_keys_idxs.append(player_idx)
		
	potential_monitors_idxs.shuffle()
	monitors_keys_idxs.append_array(potential_monitors_idxs.slice(0,monitor_keys_to_add))
	monitors_keys_idxs.sort()
	for i in range(0, 3):
		monitors_keys.append(nothings_keys[monitors_keys_idxs[i]])
	for i in range(0, 3):
		nothings_keys.erase(monitors_keys[i])
		
func spawn_monitors():
	for i in range(0, 3):
		if is_left[i]:
			monitors.append(lockon_controller.add_marker("Left_Oversampled_Wave_Cannon", party[monitors_keys[i]]))
			monitors[i].set_holder(party[monitors_keys[i]])
		else:
			monitors.append(lockon_controller.add_marker("Right_Oversampled_Wave_Cannon", party[monitors_keys[i]]))
			monitors[i].set_holder(party[monitors_keys[i]])
		party[monitors_keys[i]].add_debuff(OVERSAMPLED_WAVE_CANNON_LOADING, 10000.0, false, "Oversampled Wave Cannon Loading")
			
	await get_tree().create_timer(1.0).timeout
	var omega_monitor
	if is_left[3]:
		omega_monitor = lockon_controller.add_marker("Left_Oversampled_Wave_Cannon", final_omega)
		omega_monitor.set_holder(final_omega)
	else:
		omega_monitor = lockon_controller.add_marker("Right_Oversampled_Wave_Cannon", final_omega)
		omega_monitor.set_holder(final_omega)
	omega_monitor.scale = Vector3(1, 1, 1) * OMEGA_MONITOR_SCALE
	omega_monitor.get_node("FrontLine").visible = false
	omega_monitor.get_node("BackLine").visible = false
	monitors.append(omega_monitor)

func cast_oversampled_wave_cannon():
	cast_bar.cast("Oversampled Wave Cannon", 9.5)
	if is_left[3]:
		final_omega.play_left_monitor()
	else:
		final_omega.play_right_monitor()
		
func snapshot_monitors():
	for i in range(0, 4):
		var bodies = monitors[i].bodies
		if bodies.size() < 2:
			if i < 3:
				fail_list.add_fail("Not enough targets for monitor %s" % (i+1))
			else:
				fail_list.add_fail("Not enough targets for Final Omega monitor")
			if bodies.size() == 0:
				bodies.append(party[monitors_keys[randi_range(0,2)]])
			bodies.append(party[nothings_keys[randi_range(0,4)]])	
		if bodies.size() > 2:
			if i < 3:
				fail_list.add_fail("Too many targets for monitor %s" % (i+1))
			else:
				fail_list.add_fail("Too many targets for Final Omega monitor")
			while bodies.size() > 2:
				bodies.remove_at(randi_range(0, bodies.size()-1))
		for body in bodies:
			ground_aoe_controller.spawn_circle(body.get_pos(), MONITOR_RADIUS, 0.3, Color.AQUA, [1, 1, "Oversampled Wave Cannon"])
			body.add_debuff(MAGIC_VULNERABILITY, 5.0, false, "Magic Vulnerability")
			body.add_debuff(THRICE_COME_RUIN, 7.0, true, "Twice Come Ruin")
		monitors[i].visible = false
	for key in monitors_keys:
		party[key].remove_debuff("Oversampled Wave Cannon Loading")

func spawn_auto_markers():
	if !Global.p3_markers:
		return
	for i in range(0, 3):
		var marker = "Link_%s" % (i+1)
		lockon_controller.add_marker(marker, party[monitors_keys[i]])
		await get_tree().create_timer(0.2).timeout
	for i in range(0, 5):
		var marker = "Target_%s" % (i+1)
		lockon_controller.add_marker(marker, party[nothings_keys[i]])
		await get_tree().create_timer(0.2).timeout

func move_to_positions():
	for i in range(0, 3):
		if is_left[3]:
			party[monitors_keys[i]].move_to(MPos.MONITORS_POSITIONS_OMEGA_LEFT[i])
		else:
			party[monitors_keys[i]].move_to(MPos.MONITORS_POSITIONS_OMEGA_RIGHT[i])

	for i in range(0, 5):
		if is_left[3]:
			party[nothings_keys[i]].move_to(MPos.NOTHINGS_POSITIONS_OMEGA_LEFT[i])
		else:
			party[nothings_keys[i]].move_to(MPos.NOTHINGS_POSITIONS_OMEGA_RIGHT[i])

func adjust_monitors():
	if is_left[0]:
		party[monitors_keys[0]].look_at_direction(party[monitors_keys[0]].global_position + Vector3(0, 0, 1))
	else:
		party[monitors_keys[0]].look_at_direction(party[monitors_keys[0]].global_position + Vector3(0, 0, -1))
	if is_left[1]:
		party[monitors_keys[1]].look_at_direction(party[monitors_keys[1]].global_position + Vector3(0, 0, -1))
	else:
		party[monitors_keys[1]].look_at_direction(party[monitors_keys[1]].global_position + Vector3(0, 0, 1))
	if is_left[2]:
		if is_left[3]:
			party[monitors_keys[2]].look_at_direction(party[monitors_keys[2]].global_position + Vector3(-1, 0, 0))
		else:
			party[monitors_keys[2]].look_at_direction(party[monitors_keys[2]].global_position + Vector3(1, 0, 0))
	else:
		if is_left[3]:
			party[monitors_keys[2]].look_at_direction(party[monitors_keys[2]].global_position + Vector3(1, 0, 0))
		else:
			party[monitors_keys[2]].look_at_direction(party[monitors_keys[2]].global_position + Vector3(-1, 0, 0))
