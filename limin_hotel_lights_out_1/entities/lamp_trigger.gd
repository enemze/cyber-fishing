extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func func_on_off() -> void:
	#later on you'll need to change this to turn the emission behavior off 
	visible = !visible
	#$OmniLight3D4.visible = !$OmniLight3D4.visible
	$AudioStreamPlayer3D.playing = !$AudioStreamPlayer3D.playing
	
func func_on() -> void:
	visible = true
	$OmniLight3D4.visible = true
	$AudioStreamPlayer3D.playing = true

func func_off() -> void:
	#later on you'll need to change this to turn the emission behavior off 
	visible = false
	$OmniLight3D4.visible = false
	$AudioStreamPlayer3D.playing = false
