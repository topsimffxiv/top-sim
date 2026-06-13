extends Node

const debug = false

# Enemy asset preloads
const OMEGA_M = preload("res://scenes/p2/enemies/omega_m.tscn")
const OMEGA_F = preload("res://scenes/p2/enemies/omega_f.tscn")
const EYE = preload("res://scenes/p2/enemies/arena_eye.tscn")
const PUDDLE = preload("res://scenes/p2/enemies/omega_puddle.tscn")

# Debuff icon preloads
const REMOTE_GLITCH = preload("res://scenes/ui/auras/debuff_icons/common/remote_glitch.tscn")
const MID_GLITCH = preload("res://scenes/ui/auras/debuff_icons/common/mid_glitch.tscn")
const PACKET_FILTER_M = preload("res://scenes/ui/auras/debuff_icons/p2/packet_filter_m.tscn")
const PACKET_FILTER_F = preload("res://scenes/ui/auras/debuff_icons/p2/packet_filter_f.tscn")

# Enemy initial settings
const SCALE_FACTOR = 6*Vector3(1, 1, 1)
const START_COORDS = [Vector3(0, 0, -12.0), Vector3(0, 0, 12.0)]
const BOX_COORDS = Vector3(21.5, 0, 21.5)
const MAIN_COORDS = [Vector3(0, 0, 0), Vector3(30.41, 0, 0)] # M, F
const EYE_COORDS = [Vector3(120, 40, 0), Vector3(deg_to_rad(15), deg_to_rad(-90), 0), 2*Vector3(1, 1, 1)] # position, rotation, scale
const CLEAVE_COORDS = [Vector3(25.0, 0, 0), Vector3(-25.0, 0, 0)] # M, F

# AOE parameters
const SKATE_WIDTH = 20.0
const STAFF_WIDTH = 24.0
const SHIELD_RADIUS = 25.0
const SWORD_RADIUS = 24.0

# Tether parameters
const CHAIN_MIN_LENGTH_MID = 45.0
const CHAIN_MAX_LENGTH_MID = 55.0
const CHAIN_MIN_LENGTH_REMOTE = 85.0
const CHAIN_MAX_LENGTH_REMOTE = 95.0

# Conga prios
const NA_CONGA = ["h1", "r1", "m1", "t1", "t2", "m2", "r2", "h2"]
const SPREAD_COORDS_REMOTE = {
	"left_blue": Vector2(38, -25), "left_purple": Vector2(16, -43), "left_orange": Vector2(-16, -43), "left_green": Vector2(-38, -25),
	"right_blue": Vector2(-38, 25), "right_purple": Vector2(-16, 43), "right_orange": Vector2(16, 43), "right_green": Vector2(38, 25),
}
const SPREAD_COORDS_MID = {
	"left_blue": Vector2(38, -25), "left_purple": Vector2(12, -25), "left_orange": Vector2(-12, -25), "left_green": Vector2(-38, -25),
	"right_blue": Vector2(38, 25), "right_purple": Vector2(12, 25), "right_orange": Vector2(-12, 25), "right_green": Vector2(-38, 25)
}
const KB_LEFT_COORDS = Vector2(0.0, -6.0)
const KB_MID_COORDS = Vector2(-6.0, 0.0)
const KB_REMOTE_COORDS = Vector2(0.0, 6.0)
const STACK_MID_COORDS_LEFT = Vector2(0.0, -36.0)
const STACK_MID_COORDS_RIGHT = Vector2(-36.0, 0.0)
const STACK_REMOTE_COORDS_LEFT = Vector2(0.0, -46.0)
const STACK_REMOTE_COORDS_RIGHT = Vector2(0.0, 46.0)

# Controllers
@onready var party_synergy_anim: AnimationPlayer = %PartySynergyAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var chains_controller: ChainsController = %ChainsController
@onready var fail_list: FailList = %FailList

# Enemy instances
var omega_m_ne = OMEGA_M.instantiate()
var omega_m_se = OMEGA_M.instantiate()
var omega_m_sw = OMEGA_M.instantiate()
var omega_m_nw = OMEGA_M.instantiate()
var omega_m_main = OMEGA_M.instantiate()
var omega_m_cleave = OMEGA_M.instantiate()
var omega_f_main = OMEGA_F.instantiate()
var omega_f_cleave = OMEGA_F.instantiate()
var omega_m_final = OMEGA_M.instantiate()
var omega_f_final = OMEGA_F.instantiate()
var omega_eye = EYE.instantiate()
var puddle_m = PUDDLE.instantiate()
var puddle_f = PUDDLE.instantiate()

# Sequence variables
var party: Dictionary
var bots_visible: bool
var left_party := [] # BPOG order
var right_party := [] # BPOG order
var stack_flex: bool # true if both stacks same side
var stack_1_idx
var stack_1_left: bool # true if stack is in left_party
var stack_1_target: PlayableCharacter
var stack_2_idx
var stack_2_left: bool # true if stack_2 is in left_party
var stack_2_target: PlayableCharacter
var flex_idx
var remote: bool # true if remote glitch
var omega_f_main_staff: bool # true if staff, false if skate
var omega_m_main_sword: bool # true if sword, false if shield
var main_rotation # rotations always in radians
var cleave_rotation
var box_rotation
var eye_rotation
var omega_f_final_position
var omega_f_final_rotation
var omega_m_final_position
var omega_m_final_rotation

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. No party found.")
	ground_aoe_controller.preload_aoe(["line", "circle", "donut"])
	lockon_controller.pre_load(["PS_Cross", "PS_Circle", "PS_Square", "PS_Triangle", "Stack_Marker"])
	chains_controller.pre_load(["glitch"])
	instantiate_party(new_party)
	reset_bots_visible()
	party_synergy_anim.play("party_synergy")
	
func instantiate_party(new_party: Dictionary) -> void :
	party = new_party
	party_setup()
	
	
# Set up sequence variables
func party_setup() -> void :
	# mid or remote glitch
	if Global.p2_force_remote :
		remote = true
	elif Global.p2_force_mid :
		remote = false
	else:
		remote = randf() > 0.5
	omega_f_main_staff = randf() > 0.5
	omega_m_main_sword = randf() > 0.5
	
	# set up left and right parties
	var conga := NA_CONGA
	var color_order := [0,1,2,3,4,5,6,7]
	randomize()
	color_order.shuffle()
	for i in range(0, 7, 2) :
		var first_idx : int = color_order[i]
		var second_idx : int = color_order[i+1]
		if first_idx < second_idx :
			left_party.append(conga[first_idx])
			right_party.append(conga[second_idx])
		else :
			left_party.append(conga[second_idx])
			right_party.append(conga[first_idx])
	
	# choose stack indices
	var stack_choices := [0, 1, 2, 3]
	stack_1_idx = stack_choices.pick_random()
	stack_choices.remove_at(stack_1_idx)
	stack_2_idx = stack_choices.pick_random()
	
	# choose stack sides
	stack_1_left = randf() > 0.5
	if Global.p2_force_stack_flex:
		stack_2_left = stack_1_left
	else:
		stack_2_left = randf() > 0.5
	
	if debug :
		stack_1_left = false
		stack_2_left = false
		stack_1_idx = 1
		stack_2_idx = 2
		remote = true
	# identify flex pair
	if stack_1_left == stack_2_left :
		stack_flex = true
		if stack_1_left == true or !remote :
			if stack_1_idx < stack_2_idx :
				flex_idx = stack_1_idx
			else :
				flex_idx = stack_2_idx
		else : 
			if stack_1_idx < stack_2_idx :
				flex_idx = stack_2_idx
			else :
				flex_idx = stack_1_idx
			if Global.p2_gpob_remote and ((stack_1_idx == 1 and stack_2_idx == 2) or (stack_1_idx == 2 and stack_2_idx == 1)) :
				flex_idx = 1
			
				
	# choose main M/F rotation angle and eye rotation
	var n : int = randi_range(0,7)
	main_rotation = n * PI/4
	eye_rotation = Vector3(0, randi_range(0, 7) * PI/4, 0)
	# choose 4 male clone rotation angle, based on main_rotation
	box_rotation = (n % 2) * PI/4
	# choose cleaving M/F rotation angle
	cleave_rotation = randi_range(0,7) * PI/4 + PI/8

func spawn_bosses() -> void :
	get_tree().current_scene.add_child(omega_m_main)
	get_tree().current_scene.add_child(omega_f_main)
	omega_m_main.play_start_sword()
	omega_m_main.scale = SCALE_FACTOR
	omega_m_main.global_position = START_COORDS[0]
	omega_m_main.rotation = Vector3(0, -PI/2, 0)
	omega_f_main.play_start_staff()
	omega_f_main.scale = SCALE_FACTOR
	omega_f_main.global_position = START_COORDS[1]
	omega_f_main.rotation = Vector3(0, PI, 0)

func add_packet_debuffs() -> void :
	var i = 0
	for key in party :
		var pc = party[key]
		if i % 2 == 0:
			pc.add_debuff(PACKET_FILTER_M, 10000.0, false, "Packet Filter M")
		else:
			pc.add_debuff(PACKET_FILTER_F, 10000.0, false, "Packet Filter F")
		i += 1
		
func move_party_start() -> void :
	var conga_coords = {}
	var conga_width = 40.0
	var conga = NA_CONGA # list of conga prio
	var i = 0.0
	for elem: String in conga:
		conga_coords[elem] = Vector2(-15.0, conga_width * (-0.5 + i/7.0))
		i += 1.0
	move_party(party, conga_coords)
	
func cast_party_synergy() -> void :
	cast_bar.cast("Party Synergy", 3.0)
	omega_m_main.play_showoff()
	omega_f_main.play_showoff()
	await omega_m_main.animation_tree.animation_finished
	await omega_f_main.animation_tree.animation_finished
	omega_m_main.visible = false
	omega_f_main.visible = false
	
func add_chain_debuffs() -> void :
	var glitch
	var debuff_name
	if remote:
		glitch = REMOTE_GLITCH
		debuff_name = "Remote Glitch"
	else:
		glitch = MID_GLITCH
		debuff_name = "Mid Glitch"
	for key in party :
		party[key].add_debuff(glitch, 27.0, false, debuff_name)
		var debuff = party[key].get_debuff(debuff_name)
		debuff.debuff_timeout.connect(on_glitch_timeout)
	
func spawn_chains() -> void :
	var chains = []
	var icons = ["PS_Cross", "PS_Square", "PS_Circle", "PS_Triangle"]
	var maxlen
	var minlen
	if remote :
		maxlen = CHAIN_MAX_LENGTH_REMOTE
		minlen = CHAIN_MIN_LENGTH_REMOTE
	else :
		maxlen = CHAIN_MAX_LENGTH_MID
		minlen = CHAIN_MIN_LENGTH_MID
	for i in range(0,4) :
		var source = party[left_party[i]]
		var target = party[right_party[i]]
		chains.append(chains_controller.spawn_glitch(source, target, maxlen, minlen))
		lockon_controller.add_marker(icons[i], source)
		lockon_controller.add_marker(icons[i], target)
	
func spawn_eye() -> void :
	get_tree().current_scene.add_child(omega_eye)
	omega_eye.visible = false
	omega_eye.global_position = EYE_COORDS[0]
	omega_eye.rotation = EYE_COORDS[1]
	omega_eye.scale = EYE_COORDS[2]
	omega_eye.global_position = omega_eye.global_position.rotated(Vector3.UP, eye_rotation.y)
	omega_eye.rotation = EYE_COORDS[1] + eye_rotation
	omega_eye.visible = true

func spawn_main_and_cleave() -> void :
	get_tree().current_scene.add_child(omega_m_cleave)
	get_tree().current_scene.add_child(omega_f_cleave)
	omega_f_cleave.scale = SCALE_FACTOR
	omega_m_cleave.scale = SCALE_FACTOR
	
	var omegas = [omega_m_main, omega_f_main, omega_m_cleave, omega_f_cleave]
	for omega in omegas:
		omega.visible = false
		
	omega_m_main.global_position = MAIN_COORDS[0]
	omega_m_main.rotation = Vector3(0, randi_range(0, 7) * PI/4, 0)
	#if !omega_m_main_sword :
	#	omega_m_main.state_machine.travel("idle_shield")
	omega_f_main.global_position = MAIN_COORDS[1].rotated(Vector3.UP, main_rotation)
	omega_f_main.rotation = Vector3(0, PI + main_rotation, 0)
	#if !omega_f_main_staff :
	#	omega_f_main.state_machine.travel("idle_skates")
	#	omega_f_main.set_staff(false)
	
	omega_m_cleave.global_position = CLEAVE_COORDS[0].rotated(Vector3.UP, cleave_rotation)
	omega_m_cleave.rotation = Vector3(0, -PI/2 + cleave_rotation, 0)
	if !omega_m_main_sword :
		omega_m_cleave.play_start_sword()
	else:
		omega_m_cleave.play_start_shield()
	omega_f_cleave.global_position = CLEAVE_COORDS[1].rotated(Vector3.UP, cleave_rotation)
	omega_f_cleave.rotation = Vector3(0, cleave_rotation, 0)
	if !omega_f_main_staff :
		omega_f_cleave.play_start_staff()
	else :
		omega_f_cleave.play_start_skates()
	for omega in omegas:
		omega.visible = true

func move_party_cleave() -> void :
	var safe_spot = Vector2(0, 0)
	if omega_m_main_sword : # if cleave has shield, new center on cleave clone global_pos
		safe_spot.x = omega_m_cleave.global_position.x
		safe_spot.y = omega_m_cleave.global_position.z
		if !omega_f_main_staff : # if cleave has staff, need to adjust outward
			var adjustment_dist = SHIELD_RADIUS/2 + STAFF_WIDTH/4
			safe_spot = safe_spot + adjustment_dist * Vector2(0, 1).rotated(-cleave_rotation)
		
	else :	# cleave has sword, if skates, move under f, else move staff_width east
		if omega_f_main_staff :
			safe_spot.x = omega_f_cleave.global_position.x
			safe_spot.y = omega_f_cleave.global_position.z
		else : 
			var adjustment_dist = 0.7 * STAFF_WIDTH
			safe_spot += Vector2(0, adjustment_dist).rotated(-cleave_rotation)
	for key in party :
		var pc: PlayableCharacter = party[key]
		if pc.is_player() and !Global.spectate_mode:
			continue
		pc.move_to(safe_spot)
		
func hit_clone_cleaves() -> void : 
	if omega_f_main_staff :	
		var pos_y = 24 + SKATE_WIDTH/4
		var width = 48-SKATE_WIDTH/2
		var length = 96
		ground_aoe_controller.spawn_line(Vector2(-48, pos_y).rotated(-cleave_rotation), width, length, \
			Vector2(-38, pos_y).rotated(-cleave_rotation), 0.3, Color.IVORY, [0, 0, "Superliminal Steel"])
		ground_aoe_controller.spawn_line(Vector2(-48, -pos_y).rotated(-cleave_rotation), width, length, \
			Vector2(-38, -pos_y).rotated(-cleave_rotation), 0.3, Color.IVORY, [0, 0, "Superliminal Steel"])
	else :
		ground_aoe_controller.spawn_line(Vector2(-48, 0).rotated(-cleave_rotation), STAFF_WIDTH, 96, Vector2(0,0), \
			 0.3, Color.AQUA, [0, 0, "Optimized Blizzard III"])
		ground_aoe_controller.spawn_line(Vector2(CLEAVE_COORDS[1].x, 48).rotated(-cleave_rotation), STAFF_WIDTH, 96, \
			Vector2(omega_f_cleave.global_position.x, omega_f_cleave.global_position.z), 0.3, Color.AQUA, [0, 0, "Optimized Blizzard III"])
	if omega_m_main_sword :
		ground_aoe_controller.spawn_donut(Vector2(omega_m_cleave.global_position.x, omega_m_cleave.global_position.z), \
			SHIELD_RADIUS, 70.0, 0.3, Color.CORAL, [0, 0, "Beyond Strength"])
	else :
		ground_aoe_controller.spawn_circle(Vector2(omega_m_cleave.global_position.x, omega_m_cleave.global_position.z), \
			SWORD_RADIUS, 0.3, Color.LEMON_CHIFFON, [0, 0, "Efficient Bladework"])

func remove_ps_markers() -> void :
	var icons = ["PS_Cross", "PS_Square", "PS_Circle", "PS_Triangle"]
	for i in range(icons.size()):
		lockon_controller.remove_marker(icons[i], party[left_party[i]])
		lockon_controller.remove_marker(icons[i], party[right_party[i]])


func play_cleave_animation() -> void :
	if omega_f_main_staff :
		omega_f_cleave.play_steel()
	else :
		omega_f_cleave.play_blizzard()
	if omega_m_main_sword :
		omega_m_cleave.play_shield_slam()
	else :
		omega_m_cleave.play_chariot()
		
	await omega_f_cleave.animation_tree.animation_finished
	await omega_m_cleave.animation_tree.animation_finished
	await get_tree().create_timer(1.0).timeout
	omega_f_cleave.visible = false
	omega_m_cleave.visible = false

func play_main_idle_goop() -> void :
	#if omega_m_main_sword:
	omega_m_main.play_sword_idle_to_goop_idle()
	#else:
	#	omega_m_main.play_shield_idle_to_goop_idle()
	omega_f_main.play_idle_to_goop()
	await get_tree().create_timer(2.5).timeout

	get_tree().current_scene.add_child(puddle_m)
	get_tree().current_scene.add_child(puddle_f)
	puddle_m.global_position = omega_m_main.global_position
	puddle_f.global_position = omega_f_main.global_position
	
	omega_f_final_position = omega_m_main.global_position + Vector3(0, -20, 0)
	omega_f_final_rotation = Vector3(0, 0, 0)
	omega_m_final_position = omega_f_main.global_position + Vector3(0, -20, 0)
	omega_m_final_rotation = omega_f_main.rotation + Vector3(0, PI/2, 0)
	
	var tween_m = create_tween()
	tween_m.tween_property(omega_m_main, "position", omega_m_main.global_position + Vector3(0, -20 , 0), 1.5)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	puddle_m.play_expand()
	var tween_f = create_tween()
	tween_f.tween_property(omega_f_main, "position", omega_f_main.global_position + Vector3(0, -20 , 0), 1.5)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	puddle_f.play_expand()
	await tween_f.finished
	await tween_m.finished
	omega_f_main.queue_free()
	omega_m_main.queue_free()


func spawn_omega_box() -> void :
	var omega_list = [omega_m_ne, omega_m_se, omega_m_sw, omega_m_nw]
	var omega_model_rotation = [-3*PI/4, -PI/4, PI/4, 3*PI/4]
	var omega_position_rotation = [0, PI/2, PI, 3*PI/2]
	
	for i in range(omega_list.size()) :
		var omega = omega_list[i]
		get_tree().current_scene.add_child(omega)
		omega.play_start_sword()
		omega.scale = SCALE_FACTOR
		omega.global_position = BOX_COORDS.rotated(Vector3.UP, omega_position_rotation[i] + box_rotation)
		omega.rotation = Vector3(0, omega_model_rotation[i] + box_rotation, 0)

func move_party_spread() -> void :
	var spread_coords
	if remote:
		spread_coords = SPREAD_COORDS_REMOTE
	else:
		spread_coords = SPREAD_COORDS_MID
	var bpog_keys_left = ["left_blue", "left_purple", "left_orange", "left_green"]
	var bpog_keys_right = ["right_blue", "right_purple", "right_orange", "right_green"]
	if Global.p2_gpob_remote and remote :
		bpog_keys_right = ["right_blue", "right_orange", "right_purple", "right_green"]
	for i in range(4) :
		party[left_party[i]].move_to(spread_coords[bpog_keys_left[i]].rotated(-eye_rotation.y))
		party[right_party[i]].move_to(spread_coords[bpog_keys_right[i]].rotated(-eye_rotation.y))

func hit_eye_aoe() -> void :
	ground_aoe_controller.spawn_line(Vector2(48, 0).rotated(-eye_rotation.y), 38, 100, Vector2(0, 0), 0.3, Color.AQUAMARINE, [0, 0, "Suppression"])
	await get_tree().create_timer(2.5).timeout
	omega_eye.visible = false
		
func hit_fire_spread() -> void :
	for key in party :
		var pc = party[key]
		ground_aoe_controller.spawn_circle(Vector2(pc.global_position.x, pc.global_position.z), \
			17, 0.3, Color.DARK_ORANGE, [1, 1, "Optimized Fire III"])
		if pc.has_debuff("Vulnerability Up") :
			fail_list.add_fail(str(pc.get_name(), " did not satisfy distance requirement during Optimized Fire III"))

func return_main_omegas() -> void :
	get_tree().current_scene.add_child(omega_m_final)
	get_tree().current_scene.add_child(omega_f_final)
	omega_m_final.scale = SCALE_FACTOR
	omega_f_final.scale = SCALE_FACTOR
	omega_m_final.play_start_goop()
	omega_f_final.play_start_goop()
	omega_m_final.global_position = omega_m_final_position
	omega_m_final.rotation = omega_m_final_rotation
	omega_f_final.global_position = omega_f_final_position
	omega_f_final.rotation = omega_f_final_rotation
	
	var tween_m = create_tween()
	tween_m.tween_property(omega_m_final, "position", omega_m_final.global_position + Vector3(0, 20 , 0), 1.5)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	puddle_m.play_shrink()
	var tween_f = create_tween()
	tween_f.tween_property(omega_f_final, "position", omega_f_final.global_position + Vector3(0, 20 , 0), 1.5)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	puddle_f.play_shrink()
	
	await get_tree().create_timer(4.0).timeout
	omega_m_final.play_goop_to_idle_sword()
	omega_f_final.play_goop_to_idle()

func show_stacks() -> void :
	if stack_1_left:
		stack_1_target = party[left_party[stack_1_idx]]
	else:
		stack_1_target = party[right_party[stack_1_idx]]
	if stack_2_left:
		stack_2_target = party[left_party[stack_2_idx]]
	else:
		stack_2_target = party[right_party[stack_2_idx]]
	lockon_controller.add_marker("Stack_Marker", stack_1_target)
	lockon_controller.add_marker("Stack_Marker", stack_2_target)
	
func hide_stacks() -> void :
	lockon_controller.remove_marker("Stack_Marker", stack_1_target)
	lockon_controller.remove_marker("Stack_Marker", stack_2_target)

func hit_stacks() -> void :
	var targets = [stack_1_target, stack_2_target]
	for pc in targets :
		ground_aoe_controller.spawn_circle(Vector2(pc.global_position.x, pc.global_position.z), \
			10, 0.3, Color.AZURE, [4, 4, "Spotlight"])
		if pc.has_debuff("Vulnerability Up") :
			fail_list.add_fail(str(pc.get_name(), " did not satisfy distance requirement during Spotlight"))

func move_party_kb() -> void :
	var left_coords = KB_LEFT_COORDS.rotated(-main_rotation)
	var right_coords = KB_MID_COORDS.rotated(-main_rotation)
	if remote:
		right_coords = KB_REMOTE_COORDS.rotated(-main_rotation)
	for i in range(4) :
		if stack_flex and i == flex_idx:
			party[left_party[i]].move_to(right_coords)
			party[right_party[i]].move_to(left_coords)
		else:
			party[left_party[i]].move_to(left_coords)
			party[right_party[i]].move_to(right_coords)

func play_knockback() -> void :
	omega_f_final.play_blizzard()
	for key in party :
		var pc = party[key]
		pc.knockback(30, Vector2(0, 0))
		
func move_party_stacks() -> void :
	var left_coords = STACK_MID_COORDS_LEFT.rotated(-main_rotation)
	var right_coords = STACK_MID_COORDS_RIGHT.rotated(-main_rotation)
	if remote:
		left_coords = STACK_REMOTE_COORDS_LEFT.rotated(-main_rotation)
		right_coords = STACK_REMOTE_COORDS_RIGHT.rotated(-main_rotation)
	for i in range(4) :
		if stack_flex and i == flex_idx:
			party[left_party[i]].move_to(right_coords)
			party[right_party[i]].move_to(left_coords)
		else:
			party[left_party[i]].move_to(left_coords)
			party[right_party[i]].move_to(right_coords)

func play_box_chariots() -> void :
	var omega_list = [omega_m_ne, omega_m_se, omega_m_sw, omega_m_nw, omega_m_final]
	for omega in omega_list :
		omega.play_chariot()
		ground_aoe_controller.spawn_circle(Vector2(omega.global_position.x, omega.global_position.z), SWORD_RADIUS, 0.3, Color.LEMON_CHIFFON, [0, 0, "Efficient Bladework"])

func move_party(p: Dictionary, pos: Dictionary) -> void :
	for key: String in pos: 
		var pc: PlayableCharacter = p[key]
		if pc.is_player() and !Global.spectate_mode:
			continue
		pc.move_to(pos[key])

func toggle_bots_visible() -> void :
	if !Global.p2_hide_bots:
		return
	
	bots_visible = !Global.p2_hide_bots
	for key in party:
		var pc: PlayableCharacter = party[key]
		if pc.is_player():
			continue
		pc.visible = bots_visible
	bots_visible = !bots_visible

func reset_bots_visible() -> void :
	for key in party:
		var pc: PlayableCharacter = party[key]
		if !pc.visible:
			pc.visible = true
	Global.p2_hide_bots = get_parent().get_parent().get_node("Buttons/HideBotsButton").button_pressed

func on_glitch_timeout(owner_key) -> void :
	var pc = party[owner_key]
	var chain = pc.get_node_or_null("Chain")
	if !chain:
		return
	chain.erase_vuln()
	chains_controller.remove_chain(chain)
