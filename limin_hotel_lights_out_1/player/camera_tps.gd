extends Node3D

@export var camera_target : Node3D
@export var pitch_max = 50;
@export var pitch_min = -50;
@export var player : CharacterBody3D
var yaw = float();
var pitch = float();
var yaw_sensitivity = .002;
var pitch_sensitivity = .002;
var mouseSensibility = 550

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
func _input(event):
	if event is InputEventMouseMotion:
		if player.look_lock == false :
			if Input.get_mouse_mode() != 0 :
				yaw += -event.relative.x * yaw_sensitivity
				pitch += -event.relative.y * pitch_sensitivity
				rotation.x -= event.relative.y / mouseSensibility
				rotation.x = clamp(rotation.x,deg_to_rad(-80),deg_to_rad(80))

func _physics_process(delta: float) -> void:
	pass
	#camera_target.rotation.y = lerpf(camera_target.rotation.y,yaw,delta*10);
	#camera_target.rotation.x = lerpf(camera_target.rotation.x,pitch,delta*10);
	#pitch = clamp(pitch,deg_to_rad(pitch_min),deg_to_rad(pitch_max));
	
	
	
