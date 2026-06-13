extends Node
class_name DPos

const HAND_SPAWN_POS = [
	Vector3(23.75, 0.0, -41.13), Vector3(47.5, 0.0, 0.0), Vector3(23.75, 0.0, 41.13),
	Vector3(-23.75, 0.0, 41.13), Vector3(-47.5, 0.0, 0.0), Vector3(-23.75, 0.0, -41.13)
]

const INITIAL_TETHER_POS = [
	Vector2(20, 22), Vector2(-20, 22),
	Vector2(9, 15), Vector2(-9, 15),
	Vector2(20, -22), Vector2(-20, -22),
	Vector2(9, -15), Vector2(-9, -15)
]

const INNER_TETHER_ADJUST_POS = {
	"inner_green_north": Vector2(20, 22), "inner_green_south": Vector2(-20, 22),
	"inner_blue_north": Vector2(5.5, -22), "inner_blue_south": Vector2(-5.5, -22)
}

const OUTER_BLUE_ADJUST_POS = [
	Vector2(5.5, -22), Vector2(-5.5, -22)
]

const INNER_BLUE_POP_POS = [
	Vector2(20, -12), Vector2(-20, -12)
]

const INNER_BLUE_BEYOND_BAIT_POS = [
	Vector2(11.0, 0.0), Vector2(-11.0, 0.0)
]

const CLOCKWISE_HAND_POS = [
	Vector2(27.65, 36.71), Vector2(-19.18, 41.92),
	Vector2(45.95, -5.37), Vector2(-45.64, 5.60),
	Vector2(18.86, -41.82), Vector2(-26.95, -37.10)
]

const ANTICLOCKWISE_HAND_POS = [
	Vector2(18.67, 42.00), Vector2(-28.30, 36.43),
	Vector2(45.32, 5.86), Vector2(-44.80, -7.00),
	Vector2(28.16, -35.97), Vector2(-18.16, -42.00)
]

const GREEN_WAIT_POS = [
	Vector2(27.56, 16.54), Vector2(-27.56, 16.54),
	Vector2(27.56, -16.54), Vector2(-27.56, -16.54)
]

const GREEN_MONITOR_POS = [
	Vector2(36.94, 25.49), Vector2(-36.94, 25.49),
	Vector2(36.94, -25.49), Vector2(-36.94, -25.49)
]

const PILE_PITCH_STACK_NORTH = Vector2(5.0, 0.0)
const PILE_PITCH_STACK_SOUTH = Vector2(-5.0, 0.0)

const MONITOR_STACK_NORTH = Vector2(9.0, 0.0)
const MONITOR_STACK_SOUTH = Vector2(-9.0, 0.0)

const NOTHING_AWAY_NORTH = Vector2(3.0, 37.32)
const NOTHING_AWAY_SOUTH = Vector2(-3.0, 37.32)

const MONITOR_AWAY_NORTH = Vector2(14.37, 37.32)
const MONITOR_AWAY_SOUTH = Vector2(-14.37, 37.32)

const HELLO_WORLD_NORTH_POS = {
	"blue_nothing": Vector2(37.85, 26.62),
	"near": Vector2(15.5, 0.0), "far": Vector2(45.88, -4.16),
	"outer_green_north": Vector2(24.84, 38.64), "outer_green_south": Vector2(3.0, -45.65),
	"inner_green_north": Vector2(22.92, -22.73), "inner_green_south": Vector2(-3.0, -22.37)
}

const HELLO_WORLD_SOUTH_POS = {
	"blue_nothing": Vector2(-37.85, 26.62),
	"near": Vector2(-15.5, 0.0), "far": Vector2(-45.88, -4.16),
	"outer_green_north": Vector2(-3.0, -45.65), "outer_green_south": Vector2(-24.84, 38.64),
	"inner_green_north": Vector2(3.0, -22.37), "inner_green_south": Vector2(-22.92, -22.73)
}
const GREEN_FIRST_POP_NORTH = Vector2(8.74, -22.37)
const GREEN_FIRST_POP_SOUTH = Vector2(-8.74, -22.37)

const GREEN_WAIT_SECOND_POS = {
	"west": Vector2(0.0, -17.0), "east": Vector2(0.0, 17.0), "party": Vector2(-12.0, 0.0), "tank": Vector2(12.0, 0.0)
}

const GREEN_SECOND_POP = {
	"west": Vector2(0.0, -3.0), "east": Vector2(0.0, 3.0)
}
