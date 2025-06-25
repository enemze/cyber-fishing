extends Node3D

@export var light : Node3D
@export var whispers : Node3D
var trigger = false;
var update_check : int = 0
var on_off_check = false
@export var cardinal : int
@export var my_door : Node3D 

@onready var collision_check : Area3D = $Area3D2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trigger :
		$AudioStreamPlayer3D.play()
		#light.func_on_off()
		if update_check == 0 :
			update_check = 1
		if update_check == 2 :
			light.func_on()
			remove_from_group("show_interact_text")
			on_off_check = true
			whispers._toggle()
			update_check = 3
		trigger = false

func _update() -> void:
	if update_check == 1 :
		#light.func_off()
		whispers._toggle()
		update_check = 2
		my_door.unlock = true
		my_door.swing = true
		my_door.swing_state = 2 #if not opening outwards, set to 2 
	
func _on_timer_timeout() -> void:
	if collision_check.has_overlapping_bodies() :
		if update_check == 0:
			update_check = 1
