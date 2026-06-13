




extends Node
class_name PuddleController


@export var puddle_scene: PackedScene


func spawn_puddle(target: PlayableCharacter, puddle_count, drop_delay, duration, radius, color, target_fail_count) -> Puddle:
	var puddle: Puddle = puddle_scene.instantiate()
	self.add_child(puddle)
	puddle.instantiate_puddle(target, puddle_count, drop_delay, duration, radius, color, target_fail_count)
	return puddle
