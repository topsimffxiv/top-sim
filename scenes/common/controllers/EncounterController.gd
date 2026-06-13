




extends Node

class_name EncounterController

@onready var sequences: = get_children()

var _party

func start_encounter(party: Dictionary) -> void :
	var selected_sequence: = 0
	print("Starting sequence: ", sequences[selected_sequence].name)
	sequences[selected_sequence].start_sequence(party)


func start_p6_encounter(party: Dictionary) -> void :
	_party = party
	var selected_sequence = Global.p6_selected_seq
	print("Starting sequence: ", sequences[selected_sequence].name)
	sequences[selected_sequence].start_sequence(party)


func play_sequence_by_index(seq_index: int) -> void :
	sequences[seq_index].start_sequence(_party)
