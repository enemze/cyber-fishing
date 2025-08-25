extends Node3D

@export var pause_menu : Node3D

@onready var elevator = $entities/ElevatorDoors1

var elevator_door_state : bool = false #true = open, false = closed

#pause position stuff 
var pause_mode : bool = false
var pause_rotation_save : Vector3 = Vector3.ZERO

func _ready() -> void:
	$"../debug_light".visible = false
	await get_tree().create_timer(3).timeout
	$entities/ElevatorDoors1/AnimationPlayer.play("open")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	_swap_to_pause_menu()
	
func _swap_to_pause_menu() :
	if Input.is_action_pressed("escape") :
		if !pause_menu.swapping :
			if pause_menu.active :
				pause_menu.state = 4
			else :
				pause_menu.state = 1
