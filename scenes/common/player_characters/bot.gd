







extends PlayableCharacter


func set_parameters(new_role_key: String, new_model_scene: PackedScene, 
	spawn_position: Vector3 = Vector3.UP) -> void :
	self.name = Global.ROLE_NAMES[new_role_key] + " (Bot)"
	model_scene = new_model_scene
	role_key = new_role_key
	position = spawn_position
	is_player_character = false
