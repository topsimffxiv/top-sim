extends Node
class_name HWPos

const DEFAMATION_RADIUS = 46.0
const STACK_RADIUS = 13.0
const ROT_RADIUS = 11.0

const DEFAMATION_PATH_RADIUS = 38.0
const STACK_PATH_RADIUS = 30.0
const TETHER_PATH_RADIUS = 15.0

# not used here, for future reference only
const defam_angle_soak = PI/4
const local_angle_soak = PI/4 + PI/8 + PI/64
const stack_angle_soak = PI/8
const remote_angle_soak = PI/16

const TOWER_SOAK_POS: = {
	"left_defam": Vector2(26.87, 26.87), "right_defam": Vector2(26.87, -26.87),
	"left_remote": Vector2(-29.42, -5.85), "right_remote": Vector2(-29.42, 5.85),
	"left_stack": Vector2(-27.71, -11.48), "right_stack": Vector2(-27.71, 11.48),
	"left_local": Vector2(12.80, 35.77), "right_local": Vector2(12.80, -35.77)
}

const DODGE_ROT_POS: = {
	"left_defam": Vector2(16.66711, 24.94409), "right_defam": Vector2(16.66711, -24.94409),
	"left_remote": Vector2(-16.66711, -24.94409), "right_remote": Vector2(-16.66711, 24.94409),
	"left_stack": Vector2(-27.71638, -11.4805), "right_stack": Vector2(-27.71638, 11.4805),
	"left_local": Vector2(29.42356, 5.852712), "right_local": Vector2(29.42356, -5.852707)
}

const LEFT_SOAK_POS: = [
	TOWER_SOAK_POS["left_defam"],
	TOWER_SOAK_POS["left_remote"],
	TOWER_SOAK_POS["left_stack"],
	TOWER_SOAK_POS["left_local"]
]

const LEFT_DODGE_POS: = [
	DODGE_ROT_POS["left_defam"],
	DODGE_ROT_POS["left_remote"],
	DODGE_ROT_POS["left_stack"],
	DODGE_ROT_POS["left_local"]
]

const RIGHT_SOAK_POS: = [
	TOWER_SOAK_POS["right_defam"],
	TOWER_SOAK_POS["right_remote"],
	TOWER_SOAK_POS["right_stack"],
	TOWER_SOAK_POS["right_local"]
]

const RIGHT_DODGE_POS: = [
	DODGE_ROT_POS["right_defam"],
	DODGE_ROT_POS["right_remote"],
	DODGE_ROT_POS["right_stack"],
	DODGE_ROT_POS["right_local"]
]

const LEFT_FINAL_POS: = [
	"",
	Vector2(-6.5, -18.0),
	"",
	Vector2(-15.0, -3.0)
]

const RIGHT_FINAL_POS: = [
	"",
	Vector2(-6.5, 18.0),
	"",
	Vector2(-15.0, 3.0)
]

const STARTING_POSITIONS: = {
	"t1": Vector3(20, 0, 0), "t2": Vector3(-20, 0, 0),
	"h1": Vector3(0, 0, -20), "h2": Vector3(0, 0, 20),
	"m1": Vector3(-14.14, 0, -14.14), "m2": Vector3(-14.14, 0, 14.14),
	"r1": Vector3(14.14, 0, -14.14), "r2": Vector3(14.14, 0, 14.14)
}

# general flow
# starting clock spots, one ring inside boss ring
# move_in_out() (move tether players to tether ring distance)
#				(move rot players to defam and stack ring distance)
# move pre_position() (move everyone to pre_position assuming 0 degree rotation)
# spawn_towers()
# move_to_tower_soak_pos()
# move_to_pass_rot() (breaks remote tether)
# move_to_dodge_rot() (breaks local tether)
# repeat last 4 lines 2 times
# spawn_towers()
# move_to_final_tower_soak_pos() (both tethers to stacks)
# move_to_dodge_rot_final() (no rot pass, final position should break local tether)
