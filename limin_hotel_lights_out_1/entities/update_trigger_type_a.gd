extends Node3D

signal update_side_state(value)
@export var side_pair : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.visible = false
	
func _emit_signal() -> void:
	update_side_state.emit(side_pair)
