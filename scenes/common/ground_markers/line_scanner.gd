







extends Node3D

class_name LineScanner

signal scan_finished(areas: Array)

var areas_scanned: = []


func scan_line(starting_pos: Vector2, target_pos: Vector2, duration: float):
	self.global_position = Vector3(starting_pos.x, 0, starting_pos.y)
	self.look_at(Vector3(target_pos.x, 0, target_pos.y))

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", 
		Vector3(target_pos.x, 0, target_pos.y), duration)\
.set_trans(Tween.TRANS_LINEAR).connect("finished", on_scan_complete)

func on_scan_complete():
	scan_finished.emit(areas_scanned)
	areas_scanned = []


func _on_area_3d_area_entered(area: Area3D) -> void :
	if areas_scanned.has(area):
		print("Warning: Scanner scanned an area twice.")
		return
	areas_scanned.append(area)
