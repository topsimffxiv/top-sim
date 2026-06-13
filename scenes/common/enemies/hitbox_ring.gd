




extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_show():
    animation_player.play("show")


func play_hide():
    animation_player.play("hide")
