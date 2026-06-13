extends Node3D

var holder
var target_area
var distance
var moving
var angle

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _process(_delta):
	if moving:
		moving = false
		print(self.global_rotation)
		self.global_rotation.y = self.global_rotation.y + angle
		state_machine.travel("cbbm_sp07")
		var tween = create_tween()
		tween.tween_property(self, "global_position", target_area, 0.8)
		await tween.finished
		self.visible = false
		self.queue_free()

func set_parameters(body: Node3D):
	holder = body
	self.global_rotation.y = body.get_model_rotation().y + PI
	self.global_position = body.global_position

func snapshot_target_area() -> Vector3:
	target_area = holder.global_position
	angle = self.get_pos().angle_to(holder.get_pos()) - PI/2
	return target_area

func get_pos() -> Vector2:
	return Vector2(self.global_position.x, self.global_position.y)

func move():
	moving = true
