#todo
#modify this thing to have a centipede trail that will eventually bunch back up to it 

extends Node3D

@onready var jump_timer : Timer = $Timer
@onready var world : Node3D = $"../.."
@onready var player_detection : Area3D = $"../Area3D"
@onready var bad_stuff : Node3D = $BadStuffCollider
@onready var spawn_node : Node3D = $"../spawn_node"

var active : bool = false
var mode : int = 0 #fales = aggro mode, true = passive mode 
var passive_position_avoid : int = -1
var node_list : Array = []
var max_jumps : int = 0
var state : int = 0 #0 = normal
var jumps : int = 0
var speed : float = 0.25
var player_position_check : int = 0
var player_position_check_wait : int = false
@onready var hadex_draw_1 : Node3D = $HadexAnimator
@onready var hadex_anim_1 : AnimationPlayer = $HadexAnimator/AnimationPlayer
@onready var hadex_draw_2 : Node3D = $HadexAnimator2
@onready var hadex_anim_2 : AnimationPlayer = $HadexAnimator2/AnimationPlayer
@onready var hadex_draw_3 : Node3D = $HadexAnimator3
@onready var hadex_draw_4 : Node3D = $HadexAnimatorFlip
@onready var hadex_seg_1 : Node3D = $"../HadexSegment"
@onready var hadex_seg_2 : Node3D = $"../HadexSegment2"
var hadex_spin : float = 0
var bad_stuff_size : Vector3

@onready var audio : AudioStreamPlayer3D = $AudioStreamPlayer3D
var audio_db : float = 0.0

func _ready() -> void:
	node_list = $"../hadex_nodes".get_children(true)
	max_jumps = node_list.size()-1
	hadex_anim_1.play("sway")
	hadex_anim_2.play("pulse")
	audio_db = audio.volume_db
	audio.volume_db = -10.0
	global_position = spawn_node.global_position
	bad_stuff_size = bad_stuff.scale
	

#you're gonna want an occlusion culler exception node here! 

func _process(delta: float) -> void:
	
	if active :
		#visuals
		hadex_spin += 0.2*delta
		if hadex_spin > 360.0 :
			hadex_spin = 0.0
		hadex_draw_1.rotation.y = hadex_spin * 0.5
		hadex_draw_2.rotation.y = hadex_spin * 0.25
		hadex_draw_3.rotation.y = 360.0 - hadex_spin
		hadex_draw_4.rotation.y = 360.0 - hadex_spin
		
		var _dist = 0.2
		
		hadex_seg_1.global_rotation.y = global_rotation.y
		hadex_seg_1.global_position.x = lerp(hadex_seg_1.global_position.x,global_position.x,_dist)
		hadex_seg_1.global_position.z = lerp(hadex_seg_1.global_position.z,global_position.z,_dist)
		
		hadex_seg_2.global_rotation.y = global_rotation.y
		hadex_seg_2.global_position.x = lerp(hadex_seg_2.global_position.x,hadex_seg_1.global_position.x,_dist)
		hadex_seg_2.global_position.z = lerp(hadex_seg_2.global_position.z,hadex_seg_1.global_position.z,_dist)
		
		if mode == 0 : #aggro mode
			if state == 0 :
				_check_for_player()
				#note on node rotation: -90 for nodes that are in perpedicular halls 
				#note on node position: Y should be at 0
				global_rotation.y = move_toward(global_rotation.y,node_list[jumps].global_rotation.y,speed)
				global_position.x = move_toward(global_position.x,node_list[jumps].global_position.x,speed)
				global_position.z = move_toward(global_position.z,node_list[jumps].global_position.z,speed)
				
				if global_position.x == node_list[jumps].global_position.x :
					if global_position.z == node_list[jumps].global_position.z :
						bad_stuff.global_position.y = global_position.y
						audio.volume_db = audio_db
		if mode == 1 : #passive mode 
			match state :
				0 : #base 
					bad_stuff.global_position = global_position
					_check_for_player()
				1 : #fade away
					bad_stuff.global_position.y = -200
					audio.volume_linear = 0.0
					scale.x -= 1.0*delta
					scale.z -= 1.0*delta
					bad_stuff.global_position.y = -200
					if scale.x < 0.01 :
						scale.x = 0.0
						scale.z = 0.0
						state = 2 
				2 : # move to new position
					global_rotation.y = node_list[jumps].global_rotation.y
					global_position.x = node_list[jumps].global_position.x
					global_position.z = node_list[jumps].global_position.z
					audio.volume_db = audio_db
					state = 3
				3 : #fade in, goto 0
					scale.x += 1.0*delta
					scale.z += 1.0*delta
					if scale.x > 1.0 :
						scale = Vector3(1.0,1.0,1.0)
						bad_stuff.scale = bad_stuff_size
						state = 0
	else :
		global_position = spawn_node.global_position
		hadex_seg_1.global_position = spawn_node.global_position
		hadex_seg_2.global_position = spawn_node.global_position
					


func _check_for_player() -> void:
	if player_position_check_wait : #if we've waited a frame 
		player_position_check_wait = false
		# check position
		var _check = player_detection.get_overlapping_bodies()
		if _check.size() > 0 :
			#this is a stopgap fix; if things stop working, recheck this 
			player_position_check -= 1
			if player_position_check < 0 :
				player_position_check = max_jumps
			#this is a stopgap fix; if things stop working, recheck this 
			if mode == 0 :
				jumps = player_position_check
			if mode == 1 :
				passive_position_avoid = player_position_check
			#jump_timer.start()
		else : 
			player_position_check += 1
			if player_position_check > max_jumps :
				player_position_check = 0
	else :
		#move position
		player_detection.global_position.x = node_list[player_position_check].global_position.x
		player_detection.global_position.z = node_list[player_position_check].global_position.z
		player_position_check_wait = true

func _on_timer_timeout() -> void:
	if active : 
		if mode == 0 :
			if world.in_bad_stuff == false :
				jumps += 1
				bad_stuff.global_position.y = -200;
				audio.volume_db = -10.0
				if jumps > max_jumps :
					jumps = 0
					node_list.shuffle()
					#this will let us add more nodes in the event of, say, lights going off in the halls 
					#node_list = $"../hadex_nodes".get_children(false)
					#max_jumps = node_list.size()-1
		if mode == 1 :
			if state == 0 :
				if world.in_bad_stuff == false :
					jumps += 1
					if jumps == passive_position_avoid :
						jumps += 1
					if jumps > max_jumps :
						jumps = 0
						node_list.shuffle()
					state = 1
		
