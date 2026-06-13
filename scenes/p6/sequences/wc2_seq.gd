extends Node

var debug = false

const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const BRILLIANT_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p6/brilliant_dynamis.tscn")

const EXAFLARE = preload("res://scenes/common/ground_markers/exaflare.tscn")

@onready var wc2_anim: AnimationPlayer = %WaveCannon2Anim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var fail_list: FailList = %FailList
@onready var encounter_controller: EncounterController = %EncounterController
@onready var alpha_omega: Node3D = %AlphaOmega
@onready var hide_bots_button: CheckButton = %HideBots

var clockwise: bool # if true, rotate clockwise for baits
var exa_rotation: float # multiple of PI/4

var party
var player_key

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle"])
	instantiate_party(new_party)
	hide_bots_button.toggle_bots_visible.connect(on_toggle_bots_visible)
	
	wc2_anim.play("wc2_anim")

	
func instantiate_party(new_party: Dictionary):
	party = new_party
	randomize()

	clockwise = randf() > 0.5
	exa_rotation = randi_range(0, 7) * PI/4
	
	if debug:
		clockwise = true
		exa_rotation = PI/4
	
	for key in party:
		if party[key].is_player():
			player_key = key

func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.p6_hide_bots
	for key in party:
		if party[key].is_player():
			continue
		party[key].visible = bots_visible
	
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
		
	
func play_puddle_bait():
	var pos: Array = []
	for key in party:
		var p = party[key].get_pos()
		pos.append(p)
		ground_aoe_controller.spawn_circle(p, P6Pos.UWC_BAIT_RADIUS, 2.5, Color.GOLDENROD, [0, 0, "Unlimited Wave Cannon"], true)
	await get_tree().create_timer(3.0).timeout
	for p in pos:
		ground_aoe_controller.spawn_circle(p, P6Pos.UWC_BAIT_RADIUS, 0.9, Color.DARK_ORANGE, [0, 8, "Unlimited Wave Cannon"], false)

func play_exa_1():
	var exaflare = EXAFLARE.instantiate()
	get_tree().current_scene.add_child(exaflare)
	exaflare.global_rotation = Vector3(0, PI/2 - exa_rotation, 0)
	var pos = P6Pos.EXAFLARE_POS[0].rotated(exa_rotation)
	exaflare.global_position = Vector3(pos.x, 0, pos.y)
	await get_tree().create_timer(8.1).timeout
	exaflare.queue_free()
	for i in range(7):
		ground_aoe_controller.spawn_circle(P6Pos.EXAFLARE_POS[i].rotated(exa_rotation), P6Pos.UWC_EXA_RADIUS, 0.8, Color.DARK_ORANGE, [0, 0, "Unlimited Wave Cannon"], false)
		await get_tree().create_timer(1.0).timeout
	
func play_exa_2():
	var rot_dir: float
	if clockwise:
		rot_dir = 1.0
	else:
		rot_dir = -1.0
	var offset = rot_dir * PI/4
	
	var exaflare = EXAFLARE.instantiate()
	get_tree().current_scene.add_child(exaflare)
	exaflare.global_rotation = Vector3(0, PI/2 - offset - exa_rotation, 0)
	var pos = P6Pos.EXAFLARE_POS[0].rotated(exa_rotation + offset)
	exaflare.global_position = Vector3(pos.x, 0, pos.y)
	await get_tree().create_timer(8.1).timeout
	exaflare.queue_free()
	for i in range(7):
		ground_aoe_controller.spawn_circle(P6Pos.EXAFLARE_POS[i].rotated(exa_rotation + offset), P6Pos.UWC_EXA_RADIUS, 0.8, Color.DARK_ORANGE, [0, 0, "Unlimited Wave Cannon"], false)
		await get_tree().create_timer(1.0).timeout
	
func play_exa_3():
	var rot_dir: float
	if clockwise:
		rot_dir = 1.0
	else:
		rot_dir = -1.0
	var offset = rot_dir * PI/2
	
	var exaflare = EXAFLARE.instantiate()
	get_tree().current_scene.add_child(exaflare)
	exaflare.global_rotation = Vector3(0, PI/2 - offset - exa_rotation, 0)
	var pos = P6Pos.EXAFLARE_POS[0].rotated(exa_rotation + offset)
	exaflare.global_position = Vector3(pos.x, 0, pos.y)
	await get_tree().create_timer(8.1).timeout
	exaflare.queue_free()
	for i in range(7):
		ground_aoe_controller.spawn_circle(P6Pos.EXAFLARE_POS[i].rotated(exa_rotation + offset), P6Pos.UWC_EXA_RADIUS, 0.8, Color.DARK_ORANGE, [0, 0, "Unlimited Wave Cannon"], false)
		await get_tree().create_timer(1.0).timeout
	
func play_exa_4():
	var rot_dir: float
	if clockwise:
		rot_dir = 1.0
	else:
		rot_dir = -1.0
	var offset = rot_dir * 3*PI/4
	
	var exaflare = EXAFLARE.instantiate()
	get_tree().current_scene.add_child(exaflare)
	exaflare.global_rotation = Vector3(0, PI/2 - offset - exa_rotation, 0)
	var pos = P6Pos.EXAFLARE_POS[0].rotated(exa_rotation + offset)
	exaflare.global_position = Vector3(pos.x, 0, pos.y)
	await get_tree().create_timer(8.1).timeout
	exaflare.queue_free()
	for i in range(7):
		ground_aoe_controller.spawn_circle(P6Pos.EXAFLARE_POS[i].rotated(exa_rotation + offset), P6Pos.UWC_EXA_RADIUS, 0.8, Color.DARK_ORANGE, [0, 0, "Unlimited Wave Cannon"], false)
		await get_tree().create_timer(1.0).timeout

func snapshot_cosmo_dive():
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
		fail_list.add_fail("Cosmo Dive not correctly baited on tanks")
	var all_keys = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
	all_keys.erase(close_key_1)
	all_keys.erase(close_key_2)
	var stack_key = all_keys[randi_range(0, 5)]
	ground_aoe_controller.spawn_circle(party[close_key_1].get_pos(), P6Pos.COSMO_DIVE_BUSTER_RADIUS, \
			1.5, Color.AQUA, [1, 1, "Cosmo Dive"], false)
	ground_aoe_controller.spawn_circle(party[close_key_2].get_pos(), P6Pos.COSMO_DIVE_BUSTER_RADIUS, \
			1.5, Color.AQUA, [1, 1, "Cosmo Dive"], false)
	var aoe = ground_aoe_controller.spawn_circle(party[stack_key].get_pos(), P6Pos.COSMO_DIVE_STACK_RADIUS, \
			1.5, Color.AQUA, [6, 6, "Cosmo Dive"], false)
	aoe.collisions_checked.connect(_apply_magic_vulns)
	party[close_key_1].add_debuff(MAGIC_VULNERABILITY, 2.0, false, "Magic Vulnerability Up")
	party[close_key_2].add_debuff(MAGIC_VULNERABILITY, 2.0, false, "Magic Vulnerability Up")


func play_cast_cosmo_dive():
	cast_bar.cast("Cosmo Dive", 7.7)

func play_cast_uwc():
	cast_bar.cast("Unlimited Wave Cannon", 4.7)
	
func play_cosmo_meteor_seq():
	encounter_controller.play_sequence_by_index(4)
	
func move_uwc():
	var pos
	if clockwise:
		pos = P6Pos.UWC_BAIT_POS_CLOCKWISE
	else:
		pos = P6Pos.UWC_BAIT_POS_ANTICLOCKWISE
	for key in party:
		party[key].move_to(pos[0].rotated(exa_rotation) + Vector2(1, 0).rotated(2*PI * randf()))
	await get_tree().create_timer(8.5).timeout
	for key in party:
		party[key].move_to(pos[1].rotated(exa_rotation) + Vector2(1, 0).rotated(2*PI * randf()))
	await get_tree().create_timer(2.0).timeout
	for key in party:
		party[key].move_to(pos[2].rotated(exa_rotation) + Vector2(1, 0).rotated(2*PI * randf()))
	await get_tree().create_timer(2.0).timeout
	for key in party:
		party[key].move_to(pos[3].rotated(exa_rotation) + Vector2(1, 0).rotated(2*PI * randf()))
	await get_tree().create_timer(2.0).timeout
	for key in party:
		party[key].move_to(pos[4].rotated(exa_rotation) + Vector2(1, 0).rotated(2*PI * randf()))
	await get_tree().create_timer(2.0).timeout
	for key in party:
		party[key].move_to(pos[5].rotated(exa_rotation) + Vector2(1, 0).rotated(2*PI * randf()))
	await get_tree().create_timer(2.0).timeout
	if clockwise:
		for key in party:
			party[key].move_to(P6Pos.COSMO_DIVE_POS_2_CLOCKWISE[key].rotated(exa_rotation))
	else:
		for key in party:
			party[key].move_to(P6Pos.COSMO_DIVE_POS_2_ANTICLOCKWISE[key].rotated(exa_rotation))

	
func move_autos():
	if clockwise:
		for key in party:
			party[key].move_to(P6Pos.COSMO_DIVE_2_AUTO_POS_CLOCKWISE[key].rotated(exa_rotation))
	else:
		for key in party:
			party[key].move_to(P6Pos.COSMO_DIVE_2_AUTO_POS_ANTICLOCKWISE[key].rotated(exa_rotation))

func animate_uwc():
	alpha_omega.play_uwc()
	
func animate_cosmo_dive():
	alpha_omega.play_cosmo_dive()

func start_facing():
	alpha_omega.start_facing(party["t1"])
	
func stop_facing():
	alpha_omega.stop_facing()
