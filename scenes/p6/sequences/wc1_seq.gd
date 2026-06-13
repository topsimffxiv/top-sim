extends Node

var debug = false

const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const BRILLIANT_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p6/brilliant_dynamis.tscn")

const EXAFLARE = preload("res://scenes/common/ground_markers/exaflare.tscn")

@onready var wc1_anim: AnimationPlayer = %WaveCannon1Anim
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
	
	wc1_anim.play("wc1_anim")

	
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

func spawn_debuffs():
	for key in party:
		if !party[key].has_debuff("Brilliant Dynamis") or !party[key].has_debuff("Spark of Dynamis"):
			party[key].add_debuff(BRILLIANT_DYNAMIS, 10000.0, false, "Brilliant Dynamis")
	
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
	
func play_cosmo_arrow_2_seq():
	encounter_controller.play_sequence_by_index(2)
	
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
	for key in party:
		party[key].move_to(P6Pos.WC_PROTEAN_DODGE_POS[key])
	await get_tree().create_timer(2.0).timeout
	for key in party:
		party[key].move_to(P6Pos.WC_PROTEAN_SOAK_POS[key])
	
func move_stack_and_autos():
	for key in party:
		party[key].move_to(P6Pos.WC_STACK_POS[key])
	await get_tree().create_timer(6.0).timeout
	for key in party:
		party[key].move_to(P6Pos.WAVE_CANNON_1_AUTO_POS[key])

func animate_uwc():
	alpha_omega.play_uwc()
	
func animate_wc_stack(_target: PlayableCharacter):
	await get_tree().create_timer(0.3).timeout # 0.7 second tween
	alpha_omega.look_at(_target.global_position, Vector3(0, 1, 0), true)
	alpha_omega.play_wc_stack()

func start_facing():
	alpha_omega.start_facing(party["t1"])
	
func stop_facing():
	alpha_omega.stop_facing()
