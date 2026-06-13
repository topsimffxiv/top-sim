




extends Node
class_name GroundAoeController

enum {CIRCLE, DONUT, LINE, TOWER, CONE, LR_TOWER, PR_TOWER, WIDE_CONE, ALLEY}

const CIRCLE_Y: = 0.11
const CONE_Y: = 0.11
const LINE_Y: = 0.11
const DONUT_Y: = 0.11
const ALLEY_Y: = 0.11

@onready var marker_layer: Node3D = get_tree().get_first_node_in_group("ground_marker_layer")
@onready var res_path: = {
	"circle": "res://scenes/common/ground_markers/circle_aoe.tscn", 
	"donut": "res://scenes/common/ground_markers/donut_aoe.tscn", 
	"line": "res://scenes/common/ground_markers/line_aoe.tscn", 
	"tower": "res://scenes/common/ground_markers/tower_aoe.tscn", 
	"cone": "res://scenes/common/ground_markers/cone_aoe.tscn", 
	"diffuse_cone": "res://scenes/common/ground_markers/diffuse_cone.tscn",
	"lr_tower": "res://scenes/common/ground_markers/lr_tower_solo.tscn", 
	"pr_tower": "res://scenes/common/ground_markers/pr_tower.tscn", 
	"wide_cone": "res://scenes/common/ground_markers/wide_cone.tscn",
	"red_rot_tower": "res://scenes/p3/arena/red_rot_tower.tscn",
	"blue_rot_tower": "res://scenes/p3/arena/blue_rot_tower.tscn",
	"looper_solo_tower": "res://scenes/common/ground_markers/looper_solo.tscn",
	"looper_pair_tower": "res://scenes/common/ground_markers/looper_pair.tscn",
	"exaflare": "res://scenes/common/ground_markers/exaflare.tscn"
}

var circle_aoe_scene: PackedScene
var donut_aoe_scene: PackedScene
var line_aoe_scene: PackedScene
var tower_aoe_scene: PackedScene
var cone_aoe_scene: PackedScene
var diffuse_cone_aoe_scene: PackedScene
var ascalon_cone_scene: PackedScene
var lr_tower_scene: PackedScene
var pr_tower_scene: PackedScene
var looper_solo_tower_scene: PackedScene
var looper_pair_tower_scene: PackedScene
var wide_cone_scene: PackedScene
var red_rot_tower_scene: PackedScene
var blue_rot_tower_scene: PackedScene
var exaflare_scene: PackedScene


func preload_aoe(aoe_keys: Array) -> void :
	for key: String in aoe_keys:
		ResourceLoader.load_threaded_request(res_path[key])


func clear_all() -> void :
	for marker: Node3D in marker_layer.get_children():
		marker.queue_free()


func spawn_circle(position: Vector2, radius: float, lifetime: float, 
color: Color, fail_conditions: Array = [], check_at_end: bool = false, animation_delay: float = 0.0) -> CircleAoe:

	if !circle_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["circle"]) == 0:
			ResourceLoader.load_threaded_request(res_path["circle"])
		circle_aoe_scene = ResourceLoader.load_threaded_get(res_path["circle"])

	var new_circle: CircleAoe = circle_aoe_scene.instantiate()
	marker_layer.add_child(new_circle)
	new_circle.set_parameters(Vector3(position.x, CIRCLE_Y, position.y), radius, 
		lifetime, color, fail_conditions, check_at_end, animation_delay)
	new_circle.play_start_animation()
	if !check_at_end:
		new_circle.await_collision()
	return new_circle



func spawn_donut(position: Vector2, inner_radius: float, 
	outer_radius: float, lifetime: float, color: Color, 
	fail_conditions: = [], check_at_end: = false) -> DonutAoe:

	if !donut_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["donut"]) == 0:
			ResourceLoader.load_threaded_request(res_path["donut"])
		donut_aoe_scene = ResourceLoader.load_threaded_get(res_path["donut"])

	var new_donut: DonutAoe = donut_aoe_scene.instantiate()
	marker_layer.add_child(new_donut)
	new_donut.set_parameters(Vector3(position.x, DONUT_Y, position.y), inner_radius, outer_radius, 
		lifetime, color, fail_conditions)
	if check_at_end:
		new_donut.check_at_end()
	else:
		new_donut.await_collision()
	return new_donut


func spawn_line(position: Vector2, width: float, length: float, 
	target: Vector2, lifetime: float, color: Color, 
	fail_conditions: = [], check_at_end: = false) -> LineAoe:

	if !line_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["line"]) == 0:
			ResourceLoader.load_threaded_request(res_path["line"])
		line_aoe_scene = ResourceLoader.load_threaded_get(res_path["line"])
	var new_line: LineAoe = line_aoe_scene.instantiate()
	marker_layer.add_child(new_line)
	new_line.set_parameters(Vector3(position.x, LINE_Y, position.y), width, length, 
	 target, lifetime, color, fail_conditions)
	new_line.play_start_animation()
	if check_at_end:
		new_line.check_at_end()
	else:
		new_line.await_collision()
	return new_line




func spawn_tower(position: Vector2, radius: float, lifetime: float, color: Color) -> TowerAoe:

	if !tower_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["tower"])
		tower_aoe_scene = ResourceLoader.load_threaded_get(res_path["tower"])

	var new_tower: TowerAoe = tower_aoe_scene.instantiate()
	marker_layer.add_child(new_tower)
	new_tower.set_parameters(Vector3(position.x, 0, position.y), radius, lifetime, color)
	new_tower.play_start_animation()
	return new_tower



func spawn_lr_tower(position: Vector2, lifetime: float) -> LRTower:

	if !lr_tower_scene:
		if ResourceLoader.load_threaded_get_status(res_path["lr_tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["lr_tower"])
		lr_tower_scene = ResourceLoader.load_threaded_get(res_path["lr_tower"])

	var new_tower: LRTower = lr_tower_scene.instantiate()
	marker_layer.add_child(new_tower)
	new_tower.set_parameters(Vector3(position.x, 0, position.y), lifetime)
	new_tower.play_start_animation()
	return new_tower



func spawn_pr_tower(position: Vector2, lifetime: float) -> PRTower:

	if !pr_tower_scene:
		if ResourceLoader.load_threaded_get_status(res_path["pr_tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["pr_tower"])
		pr_tower_scene = ResourceLoader.load_threaded_get(res_path["pr_tower"])

	var new_tower: PRTower = pr_tower_scene.instantiate()
	marker_layer.add_child(new_tower)
	new_tower.set_parameters(Vector3(position.x, 0, position.y), lifetime)
	new_tower.play_start_animation()
	return new_tower

func spawn_looper_solo_tower(position: Vector2, lifetime: float) -> LooperSoloTower:

	if !looper_solo_tower_scene:
		if ResourceLoader.load_threaded_get_status(res_path["looper_solo_tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["looper_solo_tower"])
		looper_solo_tower_scene = ResourceLoader.load_threaded_get(res_path["looper_solo_tower"])

	var new_tower: LooperSoloTower = looper_solo_tower_scene.instantiate()
	marker_layer.add_child(new_tower)
	new_tower.set_parameters(Vector3(position.x, 0, position.y), lifetime)
	new_tower.play_start_animation()
	return new_tower
	
func spawn_looper_pair_tower(position: Vector2, lifetime: float) -> LooperPairTower:

	if !looper_pair_tower_scene:
		if ResourceLoader.load_threaded_get_status(res_path["looper_pair_tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["looper_pair_tower"])
		looper_pair_tower_scene = ResourceLoader.load_threaded_get(res_path["looper_pair_tower"])

	var new_tower: LooperSoloTower = looper_pair_tower_scene.instantiate()
	marker_layer.add_child(new_tower)
	new_tower.set_parameters(Vector3(position.x, 0, position.y), lifetime)
	new_tower.play_start_animation()
	return new_tower

func spawn_cone(position: Vector2, angle_deg: float, length: float, 
target: Vector2, lifetime: float, color: Color, 
fail_conditions: Array = [], check_at_end: bool = false) -> ConeAoe:

	if !cone_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["cone"]) == 0:
			ResourceLoader.load_threaded_request(res_path["cone"])
		cone_aoe_scene = ResourceLoader.load_threaded_get(res_path["cone"])
	var new_cone: ConeAoe = cone_aoe_scene.instantiate()
	marker_layer.add_child(new_cone)
	new_cone.set_parameters(Vector3(position.x, CONE_Y, position.y), angle_deg, length, 
		target, lifetime, color, fail_conditions)
	new_cone.play_start_animation()
	new_cone.await_collision()
	if check_at_end:
		new_cone.check_at_end()
	else:
		new_cone.await_collision()
	return new_cone
	
func spawn_diffuse_cone(position: Vector2, _angle_deg: float, _length: float, 
target: Vector2, lifetime: float, color: Color, 
fail_conditions: Array = [], check_at_end: bool = false) -> DiffuseConeAoe:

	if !diffuse_cone_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["diffuse_cone"]) == 0:
			ResourceLoader.load_threaded_request(res_path["diffuse_cone"])
		diffuse_cone_aoe_scene = ResourceLoader.load_threaded_get(res_path["diffuse_cone"])
	var new_cone: DiffuseConeAoe = diffuse_cone_aoe_scene.instantiate()
	marker_layer.add_child(new_cone)
	new_cone.set_parameters(Vector3(position.x, CONE_Y, position.y),
		target, lifetime, color, fail_conditions)
	new_cone.play_start_animation()
	new_cone.await_collision()
	if check_at_end:
		new_cone.check_at_end()
	else:
		new_cone.await_collision()
		
	print(new_cone.get_children())
	
	return new_cone


func spawn_wide_cone(position: Vector2, target: Vector2, lifetime: float, color: Color, 
	fail_conditions: Array = [], check_at_end: bool = false) -> WideConeAoe:

	if !wide_cone_scene:
		if ResourceLoader.load_threaded_get_status(res_path["wide_cone"]) == 0:
			ResourceLoader.load_threaded_request(res_path["wide_cone"])
		wide_cone_scene = ResourceLoader.load_threaded_get(res_path["wide_cone"])
	var new_cone: WideConeAoe = wide_cone_scene.instantiate()
	marker_layer.add_child(new_cone)
	new_cone.set_parameters(Vector3(position.x, CONE_Y, position.y), 
		target, lifetime, color, fail_conditions)
	new_cone.play_start_animation()
	new_cone.await_collision()
	if check_at_end:
		new_cone.check_at_end()
	else:
		new_cone.await_collision()
	return new_cone

func spawn_red_rot_tower(rotation: float, center_pos = Vector3(32.5, 0, 0), radius = 15.0, lifetime = 0.3, 
	_fail_conditions: Array = [], _check_at_end: bool = false) -> RedRotTower :
	
	if !red_rot_tower_scene:
		if ResourceLoader.load_threaded_get_status(res_path["red_rot_tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["red_rot_tower"])
		red_rot_tower_scene = ResourceLoader.load_threaded_get(res_path["red_rot_tower"])
	var new_rot_tower: RedRotTower = red_rot_tower_scene.instantiate()
	marker_layer.add_child(new_rot_tower)
	new_rot_tower.set_parameters(rotation, center_pos, radius, lifetime)
	new_rot_tower.play_start_animation()
	return new_rot_tower
	
func spawn_blue_rot_tower(rotation: float, center_pos = Vector3(32.5, 0, 0), radius = 15.0, lifetime = 0.3, 
	_fail_conditions: Array = [], _check_at_end: bool = false) -> BlueRotTower :
	
	if !blue_rot_tower_scene:
		if ResourceLoader.load_threaded_get_status(res_path["blue_rot_tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["blue_rot_tower"])
		blue_rot_tower_scene = ResourceLoader.load_threaded_get(res_path["blue_rot_tower"])
	var new_rot_tower: BlueRotTower = blue_rot_tower_scene.instantiate()
	marker_layer.add_child(new_rot_tower)
	new_rot_tower.set_parameters(rotation, center_pos, radius, lifetime)
	new_rot_tower.play_start_animation()
	return new_rot_tower
