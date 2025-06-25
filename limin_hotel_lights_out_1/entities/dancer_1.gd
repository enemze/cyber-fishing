extends Node3D
@onready var body_0 : Node3D = $export_all_animations_2
@onready var body_1 : Node3D = $export_all_animations_3
@onready var body_2 : Node3D = $export_all_animations_4
@onready var body_3 : Node3D = $export_all_animations_5

var active : bool = false
var toggle_anim : bool = false
var position_y : float = 0.0
var anim_int : float = 0.0

func _ready() -> void:
	position_y = global_position.y
	$export_all_animations_2/AnimationPlayer.pause()
	$export_all_animations_3/AnimationPlayer.pause()
	$export_all_animations_4/AnimationPlayer.pause()
	$export_all_animations_5/AnimationPlayer.pause()
	global_position.y = -200
	
func _process(delta: float) -> void:
	if active :
		if !toggle_anim :
			visible = true
			global_position.y = position_y
			toggle_anim = true
			$export_all_animations_2/AnimationPlayer.play()
			$export_all_animations_3/AnimationPlayer.play()
			$export_all_animations_4/AnimationPlayer.play()
			$export_all_animations_5/AnimationPlayer.play()
		
		anim_int += 1.0*delta
		if anim_int > 360.0 :
			anim_int -= 360.0
			
		body_0.rotation.y -= 1.0*delta
		body_0.position.y = -(sin(anim_int)*0.1)
		body_1.rotation.y += 2.0*delta
		body_1.position.y = (sin(anim_int)*0.2)
		body_2.rotation.y -= 3.0*delta
		body_2.position.y = -(sin(anim_int)*0.3)
		body_3.rotation.y += 4.0*delta
		body_3.position.y = (sin(anim_int)*0.4)
		
	else :
		if toggle_anim :
			visible = false
			global_position.y = -200.0
			toggle_anim = false
			$export_all_animations_2/AnimationPlayer.pause()
			$export_all_animations_3/AnimationPlayer.pause()
			$export_all_animations_4/AnimationPlayer.pause()
			$export_all_animations_5/AnimationPlayer.pause()
		
