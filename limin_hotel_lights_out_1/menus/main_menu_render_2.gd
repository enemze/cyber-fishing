extends Node3D

var rotate : float = 0.0
var base_r : float = 0.0
var vol : float = 0.0

func _ready() -> void :
	pass
	#$CoT_TV.active = true
	#base_r = $Camera3D.rotation.y 
	#$CoT_TV/AudioStreamPlayer3D.volume_linear = 0.0
	
func _process(delta) -> void :
	pass
	#rotate += delta*0.1
	#$Camera3D.rotation.y = base_r + deg_to_rad(sin(rotate)*10.0)
	#if vol < 1.0 :
		#vol += 0.1*delta
		#$CoT_TV/AudioStreamPlayer3D.volume_linear = vol
