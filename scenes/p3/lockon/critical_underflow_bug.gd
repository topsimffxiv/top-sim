extends GroundMarker
class_name CriticalUnderflowBug

signal pass_red_rot(target: Node3D)
signal rot_overlap(source: Node3D, target: Node3D)

var armed: bool

func _ready():
	self.body_entered.connect(_on_collision_area_3d_body_entered)

func _on_collision_area_3d_body_entered(body: Node3D):

	if body.has_debuff("Critical Underflow Bug") or body.has_debuff("Underflow Code Smell"):
		return
	if body.has_debuff("Critical Performance Bug"):
		rot_overlap.emit(self.get_parent().get_parent(), body)
	if armed:
		pass_red_rot.emit(body)
		
func set_armed(target: Node3D):
	armed = !target.has_debuff("Underflow Code Smell")
