extends Node
class_name SPos

const RIGHT_ARM_SPAWN_POS_1 = Vector3(-16.5, 0, 16.5)
const LEFT_ARM_SPAWN_POS_1 = Vector3(-16.5, 0, -16.5)

const OMEGA_M_SPAWN_POS_1 = Vector3(47.5, 0.0, 0.0)
const FINAL_OMEGA_SPAWN_POS = Vector3(0.0, 0.0, 0.0)
const BEETLE_OMEGA_SPAWN_POS = Vector3(-47.5, 0.0, 0.0)
const OMEGA_F_SPAWN_POS_2 = Vector3(24.5, 0.0, 0.0)

const PLAYSTATION_CONGA = [
	Vector2(39.1, -4.0), Vector2(39.1, 4.0),
	Vector2(32.8, -4.0), Vector2(32.8, 4.0),
	Vector2(26.5, -4.0), Vector2(26.5, 4.0),
	Vector2(20.2, -4.0), Vector2(20.2, 4.0)
]

const MID_GLITCH_PROTEAN_POS = {
	"north_single_unmarked": Vector2(21.5, -21.5), "north_single_marked": Vector2(-21.5, 21.5),
	"south_single_unmarked": Vector2(21.5, 21.5), "south_single_marked": Vector2(-21.5, -21.5),
	"north_double_left": Vector2(30.0, 0.0), "north_double_right": Vector2(-30.0, 0.0),
	"south_double_left": Vector2(0.0, -30.0), "south_double_right": Vector2(0.0, 30.0)
}

const REMOTE_GLITCH_PROTEAN_POS = {
	"north_single_unmarked": Vector2(32.0, -32.0), "north_single_marked": Vector2(-32.0, 32.0),
	"south_single_unmarked": Vector2(32.0, 32.0), "south_single_marked": Vector2(-32.0, -32.0),
	"north_double_left": Vector2(45.5, 0.0), "north_double_right": Vector2(-45.5, 0.0),
	"south_double_left": Vector2(0.0, -45.5), "south_double_right": Vector2(0.0, 45.5)
}

const MID_GLITCH_TOWER_SPAWN_POS = {
	"1": Vector2(37.42, -15.50), "2": Vector2(37.42, 15.50),
	"A3": Vector2(-15.50, -37.42), "B": Vector2(-37.42, -15.50),
	"C": Vector2(-37.42, 15.50), "D4": Vector2(-15.50, 37.42)
}

const REMOTE_GLITCH_TOWER_SPAWN_POS = {
	"12": Vector2(40.5, 0),
	"A": Vector2(0, -40.5), "D": Vector2(0, 40.5),
	"B3": Vector2(-28.64, -28.64), "C4": Vector2(-28.64, 28.64)
}

const MID_GLITCH_KNOCKBACK_POS = {
	"1": Vector2(5.54, -2.30), "2": Vector2(5.54, 2.30), "3": Vector2(-2.30, -5.54), "4": Vector2(-2.30, 5.54),
	"A": Vector2(-2.30, -5.54), "B": Vector2(-5.54, -2.30), "C": Vector2(-5.54, 2.30), "D": Vector2(-2.30, 5.54)
}

const REMOTE_GLITCH_KNOCKBACK_POS = {
	"1": Vector2(6.0, 0), "2": Vector2(6.0, 0), "3": Vector2(-4.24, -4.24), "4": Vector2(-4.24, 4.24),
	"A": Vector2(0, -6.0), "B": Vector2(-4.24, -4.24), "C": Vector2(-4.24, 4.24), "D": Vector2(0, 6.0)
}

const MID_GLITCH_SOAK_POS = {
	"1": Vector2(37.42, -15.50), "2": Vector2(37.42, 15.50), "3": Vector2(-15.50, -37.42), "4": Vector2(-15.50, 37.42), 
	"A": Vector2(-15.50, -37.42), "B": Vector2(-37.42, -15.50), "C": Vector2(-37.42, 15.50), "D": Vector2(-15.50, 37.42)
}

const REMOTE_GLITCH_SOAK_POS = {
	"1": Vector2(45.58, 2.10), "2": Vector2(45.58, -2.10), "3": Vector2(-33.72, -30.74), "4": Vector2(-33.72, 30.74), 
	"A": Vector2(2.10, -45.58), "B": Vector2(-30.74, -33.72), "C": Vector2(-30.74, 33.72), "D": Vector2(2.10, 45.58)
}

const CLOCKWISE_POS = {
	"south": Vector2(-43.15, 16.0), "north": Vector2(43.15, -16.0)
}

const ANTICLOCKWISE_POS = {
	"south": Vector2(-43.15, -16.0), "north": Vector2(43.15, 16.0)
}

const SKATE_POS = {
	"south": Vector2(-46.0, 0.0), "north": Vector2(46.0, 0.0)
}

const BIND_WAIT_POS = {
	"bind1": Vector2(36.0, -27), "bind2": Vector2(36.0, 27.0)
}

const HELLO_WORLD_POS = {
	"near_ccw": Vector2(0, 23.5), "target2_ccw": Vector2(0, 46.3), "target3_ccw": Vector2(-13.6, 44.0),
	"near_cw": Vector2(0, -23.5), "target2_cw": Vector2(0, -46.3), "target3_cw": Vector2(-13.6, -44.0),
	"bind1": Vector2(32.5, -32.5), "bind2": Vector2(32.5, 32.5),
	"target1": Vector2(46.0, 0), "target4": Vector2(-46.0, 0), "far": Vector2(-23.5, 0)
}
