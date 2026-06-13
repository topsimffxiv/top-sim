




extends Node

const TANKS = ["Tank 1", "Tank 2"]
const HEALERS = ["Healer 1", "Healer 2"]
const MELEE = ["Melee 1", "Melee 2"]
const RANGED = ["Ranged 1", "Ranged 2"]
const SUPPORT = TANKS + HEALERS
const DPS = MELEE + RANGED
const ALL_ROLES = SUPPORT + DPS
const ROLE_GROUP_NAMES = {"Tank": TANKS, "Healer": HEALERS, "DPS": DPS}
const ROLE_KEYS = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
const DPS_ROLE_KEYS = ["m1", "m2", "r1", "r2"]
const TANK_ROLE_KEYS = ["t1", "t2"]
const HEALER_ROLE_KEYS = ["h1", "h2"]
const ROLE_NAMES = {"t1": TANKS[0], "t2": TANKS[1], 
	"h1": HEALERS[0], "h2": HEALERS[1], 
	"m1": MELEE[0], "m2": MELEE[1], 
	"r1": RANGED[0], "r2": RANGED[1]}


var debug: = false
var deathwall_active: = true
var player_role_key: String
var selected_role_index: = 4
var selected_sequence_index: = 0
var spectate_mode: = false
var is_moving_ui: = false


var p2_hide_bots: = false
var p2_gpob_remote: = false
var p2_force_remote: = false
var p2_force_mid: = false
var p2_force_stack_flex: = false

var p3_hide_bots: = false
var p3_blue_is_defamation: = false
var p3_red_is_defamation: = false
var p3_start_defam: = false
var p3_start_stack: = false
var p3_start_local: = false
var p3_start_remote: = false
var p3_force_monitor = false
var p3_force_nothing = false
var p3_markers = true



var p4_dd_force_tether: = false
var p4_dd_force_spirit: = false


var p4_ct_selected_debuff: = 0
var p4_ct_force_spirit: = false
var p4_ct_hide_bots: = false

var p5_delta_selected_debuff: = 0
var p5_force_monitor: = false
var p5_force_beyond_defense: = false

var p5_sigma_selected_debuff: = 0
var p5_force_remote: = false
var p5_force_mid: = false
var p5_disable_markers: = false

var p5_omega_selected_dodge: = 0

var p5_selected_seq: = 0
var p5_ew_hide_bots: = false

var p6_selected_seq: = 0
var p6_continue_cycle: = false
var p6_force_inner_first: = false
var p6_force_outer_first: = false
var p6_hide_bots: = false
var p6_caster_r1: = false



var waymarks: = {
	"preset_1": {
		"wm_a": Vector2(32.3031, 0), "wm_b": Vector2(0, 32.3031), "wm_c": Vector2(-32.3031, 0), "wm_d": Vector2(0, -32.3031), 
		"wm_1": Vector2(22.7046, 22.7046), "wm_2": Vector2(-22.7046, 22.7046), "wm_3": Vector2(-22.7046, -22.7046), "wm_4": Vector2(22.7046, -22.7046), 
	}, 
	"preset_2": {
		"wm_a": Vector2(23, 0), "wm_b": Vector2(0, 23), "wm_c": Vector2(-23, 0), "wm_d": Vector2(0, -23), 
		"wm_1": Vector2(16.26, -16.26), "wm_2": Vector2(16.26, 16.26), "wm_3": Vector2(-16.26, 16.26), "wm_4": Vector2(-16.26, -16.26), 
	}, 
	"preset_3": {
		"wm_a": Vector2(40, 0), "wm_b": Vector2(0, 40), "wm_c": Vector2(-40, 0), "wm_d": Vector2(0, -40), 
		"wm_1": Vector2(28.28, -28.28), "wm_2": Vector2(28.28, 28.28), "wm_3": Vector2(-28.28, 28.28), "wm_4": Vector2(-28.28, -28.28), 
	}, 
	"current": {}
}




func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)
