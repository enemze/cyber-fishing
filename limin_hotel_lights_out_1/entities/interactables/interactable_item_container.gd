extends Node3D

@export var dialogue_string : String = ""
@export var hide_on_end_of_interact : bool = true
@export var key_int : int
@export var door_pair : Node3D
var anim_int : float = 0
var trigger : bool = false 

# Called when the node enters the scene tree for the first time.
func _ready():
	$MeshInstance3D.visible = false
	
func _process(delta):
	anim_int += 1.0*delta
	if anim_int > 360.0 :
		anim_int = 0.0
	$visual_item.position.y = (sin(anim_int)*0.1)
