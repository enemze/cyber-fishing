extends MeshInstance3D

@export var wait_time : float = 10.0
@export var flicker_duration : float = 3.0
@export var noise : NoiseTexture3D 

var flicker_interval 
var flicker : bool = false
var time_passed : float = 0.0
var energy_base : float = 0.0
var volume_base : float = 0.0
var on : bool = true

@onready var omni_light : OmniLight3D = $OmniLight3D4

func _ready() -> void:
	energy_base = omni_light.light_energy
	volume_base = $AudioStreamPlayer3D.volume_db

func _process(delta: float) -> void:
	if on :
		if flicker :
			time_passed += delta*10.0
			var sample_noise = noise.noise.get_noise_1d(time_passed)
			
			if sample_noise < 0.0: sample_noise = 0.0 
			else: sample_noise = 1.0
			
			visible = bool(sample_noise)
			$AudioStreamPlayer3D.volume_linear = sample_noise
			
			if time_passed > 10.0 :
				time_passed = time_passed - 10.0

func func_on_off() -> void:
	on = !on
	if on :
		visible = true
		$AudioStreamPlayer3D.play(randf_range(1.0,2.0))
	else:
		visible = false
		$AudioStreamPlayer3D.playing = false
		
func _on_timer_timeout() -> void:
	flicker = !flicker
	if flicker :
		$Timer.set_wait_time(flicker_duration + randf_range(-2.0,2.0))
		$Timer.start()
	else :
		visible = true
		$AudioStreamPlayer3D.volume_db = volume_base
		$Timer.set_wait_time(wait_time + randf_range(-4.0,4.0))
		$Timer.start()
