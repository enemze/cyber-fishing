extends Node3D

#just include the second trigger HERE and then make this object UNIQUE and move it 

#@export var light : Node3D
@export var wall_shadow : Sprite3D
@onready var parent : Node3D = $".."
var breaker = false
var trigger = false
var emit = false

func _ready() :
	wall_shadow.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !breaker : 
		if trigger :
			wall_shadow.visible = true
			parent.breaker = true
			$AudioStreamPlayer3D.play()
			trigger = false
			breaker = true
