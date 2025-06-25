extends Node3D

@export var play_audio : bool = true 

func _play_audio() -> void :
	$AudioStreamPlayer.play()
