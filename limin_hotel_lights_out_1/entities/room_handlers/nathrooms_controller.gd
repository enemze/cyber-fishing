extends Node3D

#needs on off update 
@onready var start_collider : Area3D = $Area3D2
var update : bool = false
var sequence_state : int = 0
@onready var exit_wall : Node3D = $WallBlack
var exit_wall_position : Vector3
#this is the door in the nathrooms maze prefab
@onready var maze : Node3D = $nathrooms_maze
@onready var door : Node3D  = $nathrooms_maze/WallDoorFull1
@onready var disappearing_switches : Node3D = $nathrooms_maze/switches
var entry_wall_position : Vector3
@onready var replacement_wall : Node3D = $Wall_001
var replacement_wall_position : Vector3 = Vector3.ZERO
@onready var world : Node3D = $"../.."
@onready var respawn_node : Node3D = $Node3D
var on_off_check = false
@onready var trigger_zone : Area3D = $click_area2
var trigger : bool = false # this is only used for when the player presses the button at the very end


@onready var my_light = $lamp_trigger_base_3
@onready var end_ref_node : Node3D = $LightSwitchVisualA/end_ref_node2
@onready var end_target : Node3D = $LightSwitchVisualA2/end_target2
@onready var end_switch_vis : Node3D = $LightSwitchVisualA2
@onready var flip_audio : AudioStreamPlayer = $AudioStreamPlayer
var tp_positional_offset : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	replacement_wall_position = replacement_wall.global_position
	replacement_wall.global_position.y = -200
	my_light.visible = false
	exit_wall_position = exit_wall.global_position
	entry_wall_position = door.global_position
	exit_wall.global_position.y -= 200
	end_switch_vis.visible = false
	world.player_died.connect(_reset_maze)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_g") :
		pass
		#sequence_state = 2.0
	
	if update == true :
		update = false 
	var _check = start_collider.get_overlapping_bodies()
	if _check.size() > 0 :
		if sequence_state == 0 :
			sequence_state = 1
			
	if trigger : 
		#turn on lights here 
		flip_audio.play()
		tp_positional_offset = end_ref_node.global_position - world.player.global_position
		world.player.global_position = end_target.global_position - tp_positional_offset
		my_light.func_on_off()
		trigger = false 
		sequence_state = 2
		remove_from_group("show_interact_text")
		on_off_check = true
		#position end ref nodes; 1 in front of end switch (with the trigger collider) and 1 in front 
		# of the dummy switch in the bedroom. 
	
	#sequence state manchine 
	if sequence_state > 0 :
		if sequence_state == 1 : # just went through 
			world.player_location = 2
			#might want to lerp player towards the collider position 
			#until they pass by a certain point, just to keep weird collisions from occuring
			exit_wall.global_position = exit_wall_position
			door.deactivate = true
			door.global_position.y = entry_wall_position.y - 200
			replacement_wall.global_position = replacement_wall_position
			world.respawn_position = respawn_node.global_position
			world.respawn_point = respawn_node
			end_switch_vis.visible = true
		if sequence_state == 2 : #after trigger has been activated 
			maze.visible = false
			exit_wall.global_position.x = exit_wall_position.x + 2.0
			world.respawn_point = world.default_respawn
			world.respawn_position = world.respawn_point.global_position
			sequence_state == 3
			#at end of sequence, be sure to reset you respawn node! 
			
			
func _reset_maze() -> void:
	print("reset maze")
	var _array = disappearing_switches.get_children(false)
	for n in _array.size() :
		_array[n].visible = true
		_array[n].position.y = 2.0
	

func _on_timer_timeout() -> void:
	update = true
