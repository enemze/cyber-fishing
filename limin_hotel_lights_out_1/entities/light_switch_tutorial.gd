extends Node3D

@export var light : Node3D
@export var sub_light : OmniLight3D
@export var whispers : Node3D
@export var corridor_lights : Node3D
@export var tutorial_barriers : Node3D
#@onready var tut_text : RichTextLabel = $RichTextLabel
#var text_pos = Vector2.ZERO
var trigger = false
var int_trigger = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	corridor_lights.visible = false;
	#text_pos = tut_text.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_g") :
		pass
		#trigger = true
	
	if int_trigger == 0 :
		pass
		#tut_text.position = Vector2(randi_range(-1,1),randi_range(-1,1)) + text_pos
	
	if trigger :
		if int_trigger == 0 :
			#tut_text.visible = false;
			$AudioStreamPlayer3D.play()
			sub_light.visible = true;
			light.func_on_off()
			tutorial_barriers.global_position.y = -999.0;
			corridor_lights.visible = true;
			int_trigger = 1
			remove_from_group("show_interact_text")
		trigger = false
