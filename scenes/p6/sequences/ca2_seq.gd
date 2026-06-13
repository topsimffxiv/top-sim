extends Node

var debug = false

const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const BRILLIANT_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p6/brilliant_dynamis.tscn")

@onready var ca2_anim: AnimationPlayer = %CosmoArrow2Anim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var fail_list: FailList = %FailList
@onready var encounter_controller: EncounterController = %EncounterController
@onready var alpha_omega: Node3D = %AlphaOmega
@onready var hide_bots_button: CheckButton = %HideBots

var inner_first: bool # if true, inner exalines go off first

var party
var player_key

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle"])
	instantiate_party(new_party)
	hide_bots_button.toggle_bots_visible.connect(on_toggle_bots_visible)
	
	ca2_anim.play("ca2_anim")

	
func instantiate_party(new_party: Dictionary):
	
	party = new_party
	
	randomize()
	if Global.p6_force_inner_first:
		inner_first = true
	elif Global.p6_force_outer_first:
		inner_first = false
	else:
		inner_first = randf() > 0.5
	
	for key in party:
		if party[key].is_player():
			player_key = key
			
	for key in party:
		if Global.p6_hide_bots and key != player_key:
			party[key].visible = false
		else:
			party[key].visible = true

func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.p6_hide_bots
	for key in party:
		if party[key].is_player():
			continue
		party[key].visible = bots_visible

func spawn_debuffs():
	for key in party:
		if !party[key].has_debuff("Brilliant Dynamis") or !party[key].has_debuff("Spark of Dynamis"):
			party[key].add_debuff(BRILLIANT_DYNAMIS, 10000.0, false, "Brilliant Dynamis")
			
func play_exalines_1():
	if inner_first:
		for i in range(2):
			ground_aoe_controller.spawn_line(P6Pos.INNER_EXALINE_INITIAL_POS.rotated(PI/2 * i), \
				P6Pos.EXALINE_WIDTH_INITIAL, P6Pos.EXALINE_LENGTH, \
				P6Pos.INNER_EXALINE_INITIAL_TGT.rotated(PI/2 * i), 5.6, Color.GOLDENROD, [0, 0, "Cosmo Arrow"], true)
		await get_tree().create_timer(7.6).timeout
		for i in range(3):
			for j in range(4):
				ground_aoe_controller.spawn_line(P6Pos.INNER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.INNER_EXALINE_TGT[i].rotated(PI/2 * j), 0.3, Color.TRANSPARENT, [0, 0, "Cosmo Arrow"])
			await get_tree().create_timer(0.2).timeout
			for j in range(4):
					ground_aoe_controller.spawn_line(P6Pos.INNER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.INNER_EXALINE_TGT[i].rotated(PI/2 * j), 1.3, Color.GOLD, [0, 8, "Cosmo Arrow"])
			await get_tree().create_timer(1.8).timeout
					
	else:
		for i in range(4):
			ground_aoe_controller.spawn_line(P6Pos.OUTER_EXALINE_INITIAL_POS.rotated(PI/2 * i), \
				P6Pos.EXALINE_WIDTH_INITIAL, P6Pos.EXALINE_LENGTH, \
				P6Pos.OUTER_EXALINE_INITIAL_TGT.rotated(PI/2 * i), 5.6, Color.GOLDENROD, [0, 0, "Cosmo Arrow"], true)
		await get_tree().create_timer(7.6).timeout
		for i in range(6):
			for j in range(4):
				ground_aoe_controller.spawn_line(P6Pos.OUTER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.OUTER_EXALINE_TGT[i].rotated(PI/2 * j), 0.3, Color.TRANSPARENT, [0, 0, "Cosmo Arrow"])
			await get_tree().create_timer(0.2).timeout
			for j in range(4):
				ground_aoe_controller.spawn_line(P6Pos.OUTER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.OUTER_EXALINE_TGT[i].rotated(PI/2 * j), 1.3, Color.GOLD, [0, 8, "Cosmo Arrow"])
			await get_tree().create_timer(1.8).timeout

func play_exalines_2():
	if !inner_first:
		for i in range(2):
			ground_aoe_controller.spawn_line(P6Pos.INNER_EXALINE_INITIAL_POS.rotated(PI/2 * i), \
				P6Pos.EXALINE_WIDTH_INITIAL, P6Pos.EXALINE_LENGTH, \
				P6Pos.INNER_EXALINE_INITIAL_TGT.rotated(PI/2 * i), 5.6, Color.GOLDENROD, [0, 0, "Cosmo Arrow"], true)
		await get_tree().create_timer(7.6).timeout
		for i in range(3):
			for j in range(4):
				ground_aoe_controller.spawn_line(P6Pos.INNER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.INNER_EXALINE_TGT[i].rotated(PI/2 * j), 0.3, Color.TRANSPARENT, [0, 0, "Cosmo Arrow"])
			await get_tree().create_timer(0.2).timeout
			for j in range(4):
					ground_aoe_controller.spawn_line(P6Pos.INNER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.INNER_EXALINE_TGT[i].rotated(PI/2 * j), 1.3, Color.GOLD, [0, 8, "Cosmo Arrow"])
			await get_tree().create_timer(1.8).timeout
					
	else:
		for i in range(4):
			ground_aoe_controller.spawn_line(P6Pos.OUTER_EXALINE_INITIAL_POS.rotated(PI/2 * i), \
				P6Pos.EXALINE_WIDTH_INITIAL, P6Pos.EXALINE_LENGTH, \
				P6Pos.OUTER_EXALINE_INITIAL_TGT.rotated(PI/2 * i), 5.6, Color.GOLDENROD, [0, 0, "Cosmo Arrow"], true)
		await get_tree().create_timer(7.6).timeout
		for i in range(6):
			for j in range(4):
				ground_aoe_controller.spawn_line(P6Pos.OUTER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.OUTER_EXALINE_TGT[i].rotated(PI/2 * j), 0.3, Color.TRANSPARENT, [0, 0, "Cosmo Arrow"])
			await get_tree().create_timer(0.2).timeout
			for j in range(4):
				ground_aoe_controller.spawn_line(P6Pos.OUTER_EXALINE_POS[i].rotated(PI/2 * j), \
					P6Pos.EXALINE_WIDTH, P6Pos.EXALINE_LENGTH, \
					P6Pos.OUTER_EXALINE_TGT[i].rotated(PI/2 * j), 1.3, Color.GOLD, [0, 8, "Cosmo Arrow"])
			await get_tree().create_timer(1.8).timeout

	
func _apply_magic_vulns(bodies: Array):
	for body in bodies:
		body.add_debuff(MAGIC_VULNERABILITY, 2.0, false, "Magic Vulnerability Up")
		
func play_auto_attack():
	alpha_omega.play_auto_attack()
	var farthest_dist = -1
	var farthest_key = ""
	for key in party:
		var dist = alpha_omega.get_pos().distance_to(party[key].get_pos())
		if dist > farthest_dist:
			farthest_dist = dist
			farthest_key = key
	if farthest_key != "t2":
		fail_list.add_fail("Auto attack not baited by T2")
		
	await get_tree().create_timer(1.0).timeout
	var aoe1 = ground_aoe_controller.spawn_circle(party["t1"].get_pos(), P6Pos.AUTO_ATTACK_RADIUS, 0.8, \
		Color.DARK_GRAY, [1, 1, "Flash Gale"])
	var aoe2 = ground_aoe_controller.spawn_circle(party[farthest_key].get_pos(), P6Pos.AUTO_ATTACK_RADIUS, 0.8, \
		Color.DARK_GRAY, [1, 1, "Flash Gale"])
	aoe1.collisions_checked.connect(_apply_magic_vulns)
	aoe2.collisions_checked.connect(_apply_magic_vulns)
		
	
func play_cast_cosmo_arrow():
	cast_bar.cast("Cosmo Arrow", 5.7)
	
func play_cast_cosmo_dive():
	cast_bar.cast("Cosmo Dive", 7.7)

func move_exalines_dps():
	var keys = ["m1", "r1", "r2", "m2"]
	await get_tree().create_timer(2.0).timeout
	var key = ""
	if inner_first:
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS[0].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout #4, 4, 6, 
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS[1].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS[2].rotated(PI/2 * i))
		await get_tree().create_timer(6.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS[3].rotated(PI/2 * i))
	else:
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS[0].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS[1].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS[2].rotated(PI/2 * i))
		await get_tree().create_timer(2.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS[3].rotated(PI/2 * i))
		await get_tree().create_timer(2.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS[4].rotated(PI/2 * i))
	

func move_exalines_supp():
	var keys = ["t2", "h1", "t1", "h2"]
	await get_tree().create_timer(2.0).timeout
	var key = ""
	if inner_first:
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS_SUPPORT[0].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout #4, 4, 6, 
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS_SUPPORT[1].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS_SUPPORT[2].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS_SUPPORT[3].rotated(PI/2 * i))
		await get_tree().create_timer(2.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.INNER_EXALINE_DODGE_POS_SUPPORT[4].rotated(PI/2 * i))
	else:
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS_SUPPORT[0].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS_SUPPORT[1].rotated(PI/2 * i))
		await get_tree().create_timer(4.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS_SUPPORT[2].rotated(PI/2 * i))
		await get_tree().create_timer(2.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS_SUPPORT[3].rotated(PI/2 * i))
		await get_tree().create_timer(2.0).timeout
		for i in range(4):
			key = keys[i]
			party[key].move_to(P6Pos.OUTER_EXALINE_DODGE_POS_SUPPORT[4].rotated(PI/2 * i))

func move_auto_attacks():
	pass

func animate_cosmo_arrow():
	alpha_omega.play_cosmo_arrow()
	
func play_wave_cannon_2_seq():
	if Global.p6_continue_cycle:
		encounter_controller.play_sequence_by_index(3)


func snapshot_proteans():
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	all_keys.shuffle()
	for i in range(0, 4):
		var line = ground_aoe_controller.spawn_line(Vector2(0, 0), P6Pos.UWC_PROTEAN_WIDTH, 50.0, party[all_keys[i]].get_pos(), 0.5, Color.GOLDENROD, [1, 1, "Wave Cannon"])
		line.collisions_checked.connect(_apply_magic_vulns)
	await get_tree().create_timer(2.0).timeout
	for i in range(4, 8):
		var line = ground_aoe_controller.spawn_line(Vector2(0, 0), P6Pos.UWC_PROTEAN_WIDTH, 50.0, party[all_keys[i]].get_pos(), 0.5, Color.GOLDENROD, [1, 1, "Wave Cannon"])
		line.collisions_checked.connect(_apply_magic_vulns)
		
func snapshot_stack():
	var dist: float
	var close_key_1 = ""
	var close_key_2 = ""
	var closest = INF
	var second_closest = INF
	for key in party:
		dist = alpha_omega.get_pos().distance_to(party[key].get_pos())
		if dist < closest:
			second_closest = closest
			closest = dist
			close_key_2 = close_key_1
			close_key_1 = key
		elif dist < second_closest:
			second_closest = dist
			close_key_2 = key
	if !["t1", "t2"].has(close_key_1) or !["t1", "t2"].has(close_key_2):
		fail_list.add_fail("Wild charge condition not satisfied")
	
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	var target = party[all_keys[randi_range(0, 7)]]
	animate_wc_stack(target)
	ground_aoe_controller.spawn_line(Vector2(0, 0), P6Pos.UWC_STACK_WIDTH, 50.0, target.get_pos(), 0.3, Color.TRANSPARENT, [8, 8, "Wave Cannon"])
	await get_tree().create_timer(1.1).timeout
	ground_aoe_controller.spawn_line(Vector2(0, 0), P6Pos.UWC_STACK_WIDTH, 50.0, target.get_pos(), 1.6, Color.GOLD, [8, 8, "Wave Cannon"])

func play_cast_uwc():
	cast_bar.cast("Unlimited Wave Cannon", 4.7)
	
func play_cast_wc():
	cast_bar.cast("Wave Cannon", 9.6)
	
func move_stack_and_autos():
	for key in party:
		party[key].move_to(P6Pos.WC_STACK_POS[key])
	await get_tree().create_timer(6.0).timeout
	for key in party:
		party[key].move_to(P6Pos.WAVE_CANNON_1_AUTO_POS[key])
	
func animate_wc_stack(_target: PlayableCharacter): # this function is called by snapshot_stack()
	await get_tree().create_timer(0.3).timeout
	alpha_omega.look_at(_target.global_position, Vector3(0, 1, 0), true)
	alpha_omega.play_wc_stack()

func start_facing():
	alpha_omega.start_facing(party["t1"])
	
func stop_facing():
	alpha_omega.stop_facing()
