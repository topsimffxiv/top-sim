




extends Node3D
class_name Enemy

func move_enemy(pos: Vector2) -> void :
    global_position = Vector3(pos.x, global_position.y, pos.y)
