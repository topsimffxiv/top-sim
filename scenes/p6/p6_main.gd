extends Sequence

func start_new_sequence() -> void :
	var player_role_index: int = SavedVariables.save_data["settings"]["player_role"]
	var selected_role: String = Global.ROLE_KEYS[player_role_index]
	var party: Dictionary = party_controller.instantiate_party(selected_role)
	if Global.p6_caster_r1:
		var temp = party["r1"]
		party["r1"] = party["r2"]
		party["r2"] = temp
	encounter_controller.start_p6_encounter(party)
