




extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_grow_in() -> void :
    animation_player.play("grow_in")
