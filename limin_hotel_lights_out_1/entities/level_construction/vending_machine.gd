extends Node3D

var trigger : bool = false

@onready var timer : Timer = $Timer
@onready var audio_clunk : AudioStreamPlayer3D = $AudioStreamPlayer3D2

func _ready() -> void :
	pass

func _process(delta) -> void :
	if timer.is_stopped() :
		if trigger :
			var _check = randi_range(0,4)
			#_check = 0
			if _check == 0 :
				audio_clunk.play()
				timer.start()
				trigger = false 
			else :
				timer.start()
				trigger = false
	else :
		trigger = false 
		
