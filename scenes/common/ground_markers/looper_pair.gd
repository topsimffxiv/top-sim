extends LooperSoloTower

class_name LooperPairTower

@onready var inner_mesh_highlight : MeshInstance3D = $InnerMeshHighlight

func check_bodies() -> void :
	if bodies <= 0:
		outer_mesh_highlight.visible = false
		inner_mesh_highlight.visible = false
		upper_glow_ring.visible = false
		soaked = SoakState.UNDER
	elif bodies == 1:
		outer_mesh_highlight.visible = true
		inner_mesh_highlight.visible = false
		upper_glow_ring.visible = false
		soaked = SoakState.UNDER
	elif bodies == 2:
		outer_mesh_highlight.visible = true
		inner_mesh_highlight.visible = true
		upper_glow_ring.visible = true
		soaked = SoakState.SOAKED
	else:
		outer_mesh_highlight.visible = true
		inner_mesh_highlight.visible = true
		upper_glow_ring.visible = true
		soaked = SoakState.OVER
