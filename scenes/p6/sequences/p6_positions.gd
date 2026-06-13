extends Node

class_name P6Pos

const EXALINE_WIDTH_INITIAL: = 23.75
const EXALINE_WIDTH: = 11.875
const EXALINE_LENGTH = 95.0

const INNER_EXALINE_INITIAL_POS = Vector2(47.5, 0.0)
const INNER_EXALINE_INITIAL_TGT = Vector2(0.0, 0.0)

const COSMO_DIVE_BUSTER_RADIUS = 13.0
const COSMO_DIVE_STACK_RADIUS = 10.0

const AUTO_ATTACK_RADIUS = 10.0

const UWC_BAIT_RADIUS = 14.35
const UWC_EXA_RADIUS = 16.3
const UWC_PROTEAN_WIDTH = 18.0
const UWC_STACK_WIDTH = 18.0

const COSMO_METEOR_BAIT_RADIUS = 24.0
const COSMO_METEOR_SPREAD_RADIUS = 15.4
const COSMO_METEOR_STACK_RADIUS = 17.0
const COSMO_METEOR_FLARE_MIN_DIST = 45.0

const INNER_EXALINE_POS = [
	Vector2(47.5, -17.8125),
	Vector2(47.5, -29.6875),
	Vector2(47.5, -41.5625)
]
const INNER_EXALINE_TGT = [
	Vector2(0, -17.8125),
	Vector2(0, -29.6875),
	Vector2(0, -41.5625)
]


const OUTER_EXALINE_INITIAL_POS = Vector2(47.5, -35.625)
const OUTER_EXALINE_INITIAL_TGT = Vector2(0, -35.625)

const OUTER_EXALINE_POS = [
	Vector2(47.5, -17.8125),
	Vector2(47.5, -5.9375),
	Vector2(47.5, 5.9375),
	Vector2(47.5, 17.8125),
	Vector2(47.5, 29.6875),
	Vector2(47.5, 41.5625)
]

const OUTER_EXALINE_TGT = [
	Vector2(0, -17.8125),
	Vector2(0, -5.9375),
	Vector2(0, 5.9375),
	Vector2(0, 17.8125),
	Vector2(0, 29.6875),
	Vector2(0, 41.5625)
]

const INNER_EXALINE_DODGE_POS = [
	Vector2(-14.5, -14.5),
	Vector2(-9.2, -9.2),
	Vector2(-25.0, -25.0),
	Vector2(-20.0, -20.0),
]

const OUTER_EXALINE_DODGE_POS = [
	Vector2(-22.0, -22.0),
	Vector2(-26.0, -26.0),
	Vector2(-22.0, -22.0),
	Vector2(-26.0, -26.0),
	Vector2(-22.0, -22.0),
]

const INNER_EXALINE_DODGE_POS_SUPPORT = [
	Vector2(-14.5, -14.5),
	Vector2(-9.2, -9.2),
	Vector2(-27.0, -13.5),
	Vector2(-27.0, 0.0), 
	Vector2(-21.5, 0.0)
]

const OUTER_EXALINE_DODGE_POS_SUPPORT = [
	Vector2(-22.0, -22.0),
	Vector2(-26.0, -26.0),
	Vector2(-21.0, -14.5),
	Vector2(-27.0, 0.0),
	Vector2(-21.5, 0.0)
]

const COSMO_DIVE_POS = {
	"t1": Vector2(12.0, -12.0), "t2": Vector2(-12.0, 12.0),
	"h1": Vector2(-20.0, -20.0), "h2": Vector2(-20.0, -20.0),
	"m1": Vector2(-20.0, -20.0), "m2": Vector2(-20.0, -20.0),
	"r1": Vector2(-20.0, -20.0), "r2": Vector2(-20.0, -20.0)
}

const COSMO_ARROW_1_AUTO_POS = {
	"t1": Vector2(15.5, 0.0), "t2": Vector2(-25.0, 25.0),
	"h1": Vector2(-18.0, -18.0), "h2": Vector2(-18.0, -18.0),
	"m1": Vector2(-18.0, -18.0), "m2": Vector2(-18.0, -18.0),
	"r1": Vector2(-18.0, -18.0), "r2": Vector2(-18.0, -18.0)
}

const EXAFLARE_POS = [
	Vector2(48.9, 0), Vector2(32.6, 0), Vector2(16.3, 0), Vector2(0, 0),
	Vector2(-16.3, 0), Vector2(-32.6, 0), Vector2(-48.9, 0)
]

const UWC_BAIT_POS_CLOCKWISE = [
	Vector2(0.0, 0.0), Vector2(12.0, -12.0), Vector2(25.0, -25.0), Vector2(34.0, -10.0),
	Vector2(34.0, 10.0), Vector2(25.0, 25.0)
]

const UWC_BAIT_POS_ANTICLOCKWISE = [
	Vector2(0.0, 0.0), Vector2(12.0, 12.0), Vector2(25.0, 25.0), Vector2(34.0, 10.0),
	Vector2(34.0, -10.0), Vector2(25.0, -25.0)
]

const WC_PROTEAN_DODGE_POS = {
	"t1": Vector2(16.0, 0.0), "r2": Vector2(11.2, 11.2), "h2": Vector2(0.0, 16.0), "m2": Vector2(-11.2, 11.2),
	"t2": Vector2(-16.0, 0.0), "m1": Vector2(-11.2, -11.2), "h1": Vector2(0.0, -16.0), "r1": Vector2(11.2, -11.2)
}

const WC_PROTEAN_SOAK_POS = {
	"t1": Vector2(28.7, 0.0), "r2": Vector2(19.5, 19.5), "h2": Vector2(0.0, 28.7), "m2": Vector2(-19.5, 19.5),
	"t2": Vector2(-28.7, 0.0), "m1": Vector2(-19.5, -19.5), "h1": Vector2(0.0, -28.7), "r1": Vector2(19.5, -19.5)
}

const WC_STACK_POS = {
	"t1": Vector2(-11.0, -1.0), "t2": Vector2(-11.0, 1.0), "h1": Vector2(-24.0, 0.0), "h2": Vector2(-24.0, 0.0),
	"m1": Vector2(-24.0, 0.0), "m2": Vector2(-24.0, 0.0), "r1": Vector2(-24.0, 0.0), "r2": Vector2(-24.0, 0.0),
}

const WAVE_CANNON_1_AUTO_POS = {
	"t1": Vector2(15.5, 0.0), "t2": Vector2(-25.0, -25.0),
	"h1": Vector2(-18.0, 0), "h2": Vector2(-18.0, 0),
	"m1": Vector2(-18.0, 0), "m2": Vector2(-18.0, 0),
	"r1": Vector2(-18.0, 0), "r2": Vector2(-18.0, 0)
}

const COSMO_DIVE_POS_2_CLOCKWISE = {
	"t1": Vector2(-18.0, 0.0), "t2": Vector2(18.0, 0.0),
	"h1": Vector2(5, 30.0), "h2": Vector2(5, 30.0),
	"m1": Vector2(5, 30.0), "m2": Vector2(5, 30.0),
	"r1": Vector2(5, 30.0), "r2": Vector2(5, 30.0)
}

const COSMO_DIVE_POS_2_ANTICLOCKWISE = {
	"t1": Vector2(18.0, 0.0), "t2": Vector2(-18.0, 0.0),
	"h1": Vector2(5, -30.0), "h2": Vector2(5, -30.0),
	"m1": Vector2(5, -30.0), "m2": Vector2(5, -30.0),
	"r1": Vector2(5, -30.0), "r2": Vector2(5, -30.0)
}

const COSMO_DIVE_2_AUTO_POS_CLOCKWISE = {
	"t1": Vector2(-18.0, 0.0), "t2": Vector2(35.0, 0.0),
	"h1": Vector2(0, 20.0), "h2": Vector2(0, 20.0),
	"m1": Vector2(0, 20.0), "m2": Vector2(0, 20.0),
	"r1": Vector2(0, 20.0), "r2": Vector2(0, 20.0)
}

const COSMO_DIVE_2_AUTO_POS_ANTICLOCKWISE = {
	"t1": Vector2(18.0, 0.0), "t2": Vector2(-35.0, 0.0),
	"h1": Vector2(0, -20.0), "h2": Vector2(0, -20.0),
	"m1": Vector2(0, -20.0), "m2": Vector2(0, -20.0),
	"r1": Vector2(0, -20.0), "r2": Vector2(0, -20.0)
}

const COSMO_METEOR_SPREAD_POS_CASTER_R1 = {
	"r2": Vector2(32.5, 0), "t1": Vector2(23, 23), 
	"h2": Vector2(0, 32.5), "m2": Vector2(-23, 23),
	"t2": Vector2(-32.5, 0), "m1": Vector2(-23, -23),
	"h1": Vector2(0, -32.5), "r1": Vector2(23, -23)
}

const COSMO_METEOR_SPREAD_POS_CASTER_R2 = {
	"r1": Vector2(32.5, 0), "t1": Vector2(23, -23), 
	"h2": Vector2(0, 32.5), "m2": Vector2(-23, 23),
	"t2": Vector2(-32.5, 0), "m1": Vector2(-23, -23),
	"h1": Vector2(0, -32.5), "r2": Vector2(23, 23)
}
