extends CharacterBody3D

const JUMP_VELOCITY = 12*0.8
var mouseSensibility = 550
var mouse_relative_x = 0
var mouse_relative_y = 0
var jump_token = 2;
var consecWallJumps = 0;

@onready var ray_shadow = $D_Shad_Check
@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var drop_shadow = $Drop_Shadow
@onready var stp_audio_player = $footsteps
@onready var audio_s_player = $AudioStreamPlayer
@onready var p_collider = $CollisionShape3D
@onready var default_height
@onready var head_bonk = $head_bonk
@onready var ladder_detection = $ladder_detection
@onready var timer_shake = $Timer
@onready var step_audio_detection : RayCast3D = $step_audio_detect
@onready var interact_text : RichTextLabel = $HUD/interact_text
@onready var interact_cast : RayCast3D = $Head/Camera3D/interact_cast
@onready var interact_cooldown : Timer = $HUD/interact_cooldown

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30.0
var fall = 30.0
var bs_spd = 3.0
var spd = 3.0
var spd_crch_mod = 0.5
var p_normal
var direction
var mantling = false
var sprint_mod = 2
var sprint_spd = 0
var land_audio = false;
var fov_default = 0.0;
var fov_sprint = 0.0;
var sprint = false;
var eyes_state = 0;
var eyes_state_sub_timer = 0
var close_game = false
var fall_fade = 0;
var fall_color_white = Color(Color.WHITE)
var fall_tween 
var point_timer = 0
var fog_fade = false
var teleport_point 
var fall_thresh = 100;
var crouch_speed = 20;
var crouch_height = 0;
var head_default = 0;
var ceil_too_low = false
var on_ladder = false
var can_wall_run = true
var pause = false
var blink_frames = 0
var collisionInst = null
var wallTouched = false
var allowWallJump = false
var entity_inst = null
var fish_clicked = false
var fired_cash = false
var bootGrabbed = false
var cam_shake = false
var shake_strength = 0.0
var SHAKE_DECAY_RATE = 0.35
var accBunnyHop = false
var BUNNY_SPEED_MULT = 0.0
var frame_check = 0
var bunny_fired = false
var compClicked = false

var wall_run_angle = 15 #export me 
var wall_run_current_angle = 0
var wall_run_fov = 90
var wall_run_current_FOV = 0
#@onready var wall_run_default_fov = $Head/Camera3D.fov

var wall_run_x_rot = 0
var wall_run_x_vec = Vector2.ZERO
var wall_run_dir_ex = 0
var dot_ex = 0

var step_timer = 0;

var in_dialogue = false;

var step_aud_carpet = load("res://resources/sounds/freesound/38872__swuing__footstep-carpet.wav")

func _ready():
	#$"/root/global".register_player(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #captures mouse inside the screenspace
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("timeline_null_reset") #this preloads the dialogic system
	#fov_default = camera.fov;
	#fov_sprint = fov_default + 5.0;
	#default_height = p_collider.scale.y
	#crouch_height = default_height*0.6
	#head_default = head.position.y
	process_mode = Node.PROCESS_MODE_ALWAYS;
		
func _process(delta):

#----------------------------------------------------------------------------------------
#screenshake
#----------------------------------------------------------------------------------------
	if(cam_shake == true):
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.h_offset = randf_range(-shake_strength, shake_strength)
		camera.v_offset = randf_range(-shake_strength, shake_strength)
		
#----------------------------------------------------------------------------------------
#step audio
#----------------------------------------------------------------------------------------
	if step_timer > 30 :
		
		var _check = step_audio_detection.get_collider();
		if _check != null :
			if _check.get_parent().is_in_group("carpet") :
				pass
				#change audio from loaded audio variables 
		step_timer = 0;
		stp_audio_player.pitch_scale = randf_range(0.7,1.3);
		stp_audio_player.play()
			
	#check ceiling depth when crouching
	#ceil_too_low = false
	#if head_bonk.is_colliding() :
		#ceil_too_low = true
		

#----------------------------------------------------------------------------------------
#dialogue handling #dialogic
#----------------------------------------------------------------------------------------

	var _check = interact_cast.get_collider();
	if _check != null :
		if !in_dialogue :
			interact_text.text = "Press LMB"
		else:
			interact_text.text = ""
		
		if Input.is_action_just_pressed("shoot") :
			if _check.get_parent().is_in_group("has_dialogue"):
				if !in_dialogue :
					in_dialogue = true
					Dialogic.start(_check.get_parent().dialogue_string)
					entity_inst = _check.get_parent()
	else :
		interact_text.text = ""
	


#Dialogic.start(dialogue_string)
#if dialogic "end" signal sent, in_dialogue = false 
func _on_timeline_ended():
	interact_cooldown.start()
	if entity_inst != null :
		if entity_inst.hide_on_end_of_interact:
			entity_inst.visible = false;
			entity_inst.global_position.y = -100
	
#checks for dialogic signals w/ string arguments and does "something"
func _on_dialogic_signal(argument:String):
	if argument == "d_end":
		in_dialogue = false;
		print("Something was activated!")
	if argument == "dialogue_exhausted":
		pass
		
func _on_interact_cooldown_timeout():
	in_dialogue = false

func _input(event):
#----------------------------------------------------------------------------------------
#mouse look input
#----------------------------------------------------------------------------------------
	if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / mouseSensibility 
			#camera.rotation.x -= event.relative.y / mouseSensibility
			#camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
			mouse_relative_x = clamp(event.relative.x,deg_to_rad(-50),deg_to_rad(50))
			mouse_relative_y = clamp(event.relative.y,deg_to_rad(-50),deg_to_rad(50))
#----------------------------------------------------------------------------------------
#quit
#----------------------------------------------------------------------------------------
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	
func angle_to_angle(from, to): #for radians
	return fposmod(to-from + PI, PI*2) - PI	
	
func angle_difference(angle1, angle2): #for degrees
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))

func _physics_process(delta):
				
#----------------------------------------------------------------------------------------
#ladder & door detection
#----------------------------------------------------------------------------------------
	#if ladder_detection.has_overlapping_areas() :
		#var collision = ladder_detection.get_overlapping_areas();
		#var check = collision[0].get_parent();
		#
		#if check.is_in_group("door"):
			#if Input.is_action_just_pressed("shoot") :
				#var test_a = check.global_transform.origin - global_transform.origin;
				#var _dot = test_a.dot(check.global_transform.basis.z)
				#check.swing = true
				#check.swing_direction = _dot
#----------------------------------------------------------------------------------------
#jump reset
#----------------------------------------------------------------------------------------
	if is_on_floor():
		frame_check += 1
		jump_token = 1;

		#if land_audio :
			#land_audio = false
			#step_timer = 0;
			#stp_audio_player.pitch_scale = randf_range(0.7,1.3);
			#stp_audio_player.play()

#----------------------------------------------------------------------------------------
#handle jump launch
#----------------------------------------------------------------------------------------
	#
	#if Input.is_action_just_pressed("ui_accept"):
		#frame_check = 0
		#if jump_token > 0 :
			#jump_token -= 1;
			##land_audio = true;
			#velocity.y = JUMP_VELOCITY
					#
	
	
#----------------------------------------------------------------------------------------
#crouch behavior
#----------------------------------------------------------------------------------------
	if Input.is_action_pressed("crouch") :
		p_collider.scale.y -= crouch_speed * delta;
		head.position.y -= crouch_speed * delta;
		spd = bs_spd - ((bs_spd*spd_crch_mod) * int(is_on_floor()));
	elif !ceil_too_low :
		p_collider.scale.y += crouch_speed * delta;
		head.position.y += crouch_speed * delta;
	p_collider.scale.y = clamp(p_collider.scale.y,crouch_height,default_height)
	head.position.y = clamp(head.position.y,head_default-0.5,head_default)
	
	if not is_on_floor():
		if !on_ladder :
			velocity.y -= fall * delta


#----------------------------------------------------------------------------------------
#sprint behavior
#----------------------------------------------------------------------------------------
	if Input.is_action_pressed("sprint") && Input.is_action_pressed("forward"):
		sprint_spd = sprint_mod
		camera.fov = lerp(camera.fov,fov_sprint,0.1);
		if is_on_floor() && spd < bs_spd + sprint_spd :
			spd += sprint_spd
	else:
		camera.fov = lerp(camera.fov,fov_default,0.1);
		sprint_spd = 0
		sprint = false

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	p_normal = direction
	
#----------------------------------------------------------------------------------------
#movement & ladder movement
#----------------------------------------------------------------------------------------
	if on_ladder :
		pass
		#var look_mod = 1 + abs(camera.global_transform.basis.z.y);
		#var forward_vec = Vector3.FORWARD
		#var right_vec = Vector3.RIGHT
		#var forward = Vector3()
		#var right = Vector3()
#
		## in the function before you move things
		#var basis = camera.global_transform.basis
		#var sub_spd = int(Input.is_action_pressed("forward")) - int(Input.is_action_pressed("back")) 
		#var sub_spd_r = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
		#var b_spd = bs_spd*0.5
		#forward = basis * forward_vec * sub_spd 
		#right = basis * right_vec * sub_spd_r 
		#velocity = (forward + right) * (b_spd * look_mod)
		
	else:
		if is_on_floor() :
			if direction:
				velocity.x = direction.x * spd
				velocity.z = direction.z * spd
			else:
				velocity.x = move_toward(velocity.x, 0, spd)
				velocity.z = move_toward(velocity.z, 0, spd)
		else:
			if direction :
				velocity.x = move_toward(velocity.x,direction.x*spd,0.5);
				velocity.z = move_toward(velocity.z,direction.z*spd,0.5);


	move_and_slide()
	if is_on_floor() || on_ladder:
		if input_dir != Vector2.ZERO :
			step_timer += (spd / bs_spd);
			
	spd = bs_spd
	
#----------------------------------------------------------------------------------------
#drop shadow
#----------------------------------------------------------------------------------------
	drop_shadow.global_position.y = ray_shadow.get_collision_point().y + 0.01
	drop_shadow.global_position.x = global_position.x
	drop_shadow.global_position.z = global_position.z
#
	drop_shadow.rotate_y(0.01)

#----------------------------------------------------------------------------------------
#screenshake cleanup
#----------------------------------------------------------------------------------------
#func _on_timer_timeout():
	#shake_strength = 1.5
	#cam_shake = true
	#timer_shake.start()
#
#
#func _on_timer_timeout_player():
	#camera.h_offset = 0.0
	#camera.v_offset = 0.0
	#cam_shake = false
