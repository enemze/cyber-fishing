extends Node3D

@export var my_light : Node3D
@export var b_room_light : Node3D
@export var my_door : Node3D
@export var player : CharacterBody3D
@onready var critter : Node3D = $Sprite3D
@onready var switch_audio : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var look_point : Node3D = $look_point
var trigger : bool = false
var state : int = 0
var wait_time : float = 4.0
var wait_timer : float = 0.0
var on_off_check : bool = false
var reveals_position_array : Array = []

func _ready() -> void :
	critter.visible = false
	var _reveals = $reveals.get_children()
	for n in _reveals.size(): 
		reveals_position_array.append(_reveals[n].global_position)
		_reveals[n].global_position.y = -200
	
func _process(delta) -> void :
	if trigger:
		match state :
			0 : #when switch flicked, turn on light, close & lock door, spawn entity 
				switch_audio.play()
				state += 1
				my_light.func_on_off()
				critter.visible = true
				#you'll need to manually reset these later; possibly make this a script inside the door later 
				my_door.deactivate = true
				my_door.swing_state = 0
				my_door.swing = false
				my_door.collider.global_position.y = my_door.collider_y
				my_door.door_vis.rotation.y = my_door.base_rotation
			1 : #if player looks at entity, goto 2
				look_point.look_at(player.global_position)
				var _dot = player.global_transform.basis.z.angle_to(-look_point.global_transform.basis.z)
				if _dot < 1 :
					state = 2
				if $walk_back_check.has_overlapping_bodies() :
					state = 2 
				
			2: #turn off light after very short wait / animation
				#either wait or play animation here 
				wait_timer += 10.0*delta
				if wait_timer > wait_time :
					critter.visible = false
					switch_audio.play()
					state += 1
					my_light.func_on_off()
					trigger = false
			3: #wait until player clicks switch again
				my_door.deactivate = false
				on_off_check = true
				remove_from_group("show_interact_text")
				switch_audio.play()
				my_light.func_on_off()
				b_room_light.func_on_off()
				state += 1
				var _reveals = $reveals.get_children()
				for n in _reveals.size(): 
					_reveals[n].global_position = reveals_position_array[n]
			4: #if done, don't do anything 
				trigger = false
		
