extends Node3D

@onready var elevator = $entities/ElevatorDoors1

var elevator_door_state : bool = false #true = open, false = closed


func _ready() -> void:
	await get_tree().create_timer(3).timeout
	$entities/ElevatorDoors1/AnimationPlayer.play("open")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
