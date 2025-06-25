extends MeshInstance3D

@export var wait_time : float = 10.0
@export var flicker_duration : float = 4.0
@export var noise : NoiseTexture3D 
#@export var flicker_mat : StandardMaterial3D

var active : bool = false
var flicker_interval 
var flicker : bool = false
var time_passed : float = 0.0
var energy_base : float = 0.0
var volume_base : float = 0.0

@onready var omni_light : OmniLight3D = $OmniLight3D4

func _ready() -> void:
	energy_base = omni_light.light_energy
	volume_base = $AudioStreamPlayer3D.volume_db
	#flicker_mat.albedo_color = Color(0.0,0.0,0.0,0.0)

func _process(delta: float) -> void:
	if active :
		if !flicker:
			$Timer.start(flicker_duration + randf_range(-2.0,2.0))
			flicker = true
		if flicker :
			time_passed += delta*10.0
			var sample_noise = noise.noise.get_noise_1d(time_passed)
			
			if sample_noise < 0.0: sample_noise = 0.0 
			else: sample_noise = 1.0
			
			visible = bool(sample_noise)
			$AudioStreamPlayer3D.volume_linear = sample_noise
			
			if time_passed > 10.0 :
				time_passed = time_passed - 10.0
				
func _on_timer_timeout() -> void:
	active = false
	flicker = false
