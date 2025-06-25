extends Node3D

@export var light : Node3D
var trigger = false;
var emit = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trigger :
		if light.visible == false :
			$AudioStreamPlayer3D.play()
			light.func_on_off()
			emit = true
			trigger = false
