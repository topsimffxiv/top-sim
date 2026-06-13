extends Node

var debug = false

const MAGIC_VULNERABILITY = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln.tscn")
const BRILLIANT_DYNAMIS = preload("res://scenes/ui/auras/debuff_icons/p6/brilliant_dynamis.tscn")

const EXAFLARE = preload("res://scenes/common/ground_markers/exaflare.tscn")

@onready var cm_anim: AnimationPlayer = %CosmoMeteorAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var fail_list: FailList = %FailList
@onready var encounter_controller: EncounterController = %EncounterController
@onready var alpha_omega: Node3D = %AlphaOmega
@onready var hide_bots_button: CheckButton = %HideBots

var party
var player_key

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle"])
	instantiate_party(new_party)
	hide_bots_button.toggle_bots_visible.connect(on_toggle_bots_visible)
	
	cm_anim.play("cm_anim")

	
func instantiate_party(new_party: Dictionary):
	party = new_party
	randomize()
	
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
		
func puddle_bait():
	for key in party:
		ground_aoe_controller.spawn_circle(party[key].get_pos(), P6Pos.COSMO_METEOR_BAIT_RADIUS, 4.0, Color.GOLDENROD, [0, 0, "Cosmo Meteor"], true)

func move_bait():
	for key in party:
		party[key].move_to(Vector2(0, 0))

func move_spread():
	var pos
	if Global.p6_caster_r1:
		pos = P6Pos.COSMO_METEOR_SPREAD_POS_CASTER_R1
	else:
		pos = P6Pos.COSMO_METEOR_SPREAD_POS_CASTER_R2
	for key in party:
		party[key].move_to(pos[key])

func face_north():
	var tween = create_tween()
	tween.tween_property(alpha_omega, "global_rotation", Vector3(0, PI/2, 0), 0.3)
	await tween.finished

func cast_cosmo_meteor():
	cast_bar.cast("Cosmo Meteor", 4.1)

func animate_cosmo_meteor():
	alpha_omega.play_cosmo_meteor()

func start_facing():
	alpha_omega.start_facing(party["t1"])
	
func stop_facing():
	alpha_omega.stop_facing()
