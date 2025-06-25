extends MeshInstance3D

func func_on_off() -> void:
	#later on you'll need to change this to turn the emission behavior off 
	visible = !visible
	$OmniLight3D4.visible = !$OmniLight3D4.visible
	$AudioStreamPlayer3D.playing = !$AudioStreamPlayer3D.playing
