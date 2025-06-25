extends StaticBody3D

@export var state : int = 0
@export var jitter : bool = true

@export var tv_screen_off : MeshInstance3D
@export var tv_screen_on : MeshInstance3D
@export var mat: StandardMaterial3D
@export var omni_light : OmniLight3D
#@export var spot_light : SpotLight3D
@export var noise : NoiseTexture3D 
@export var screen_noise : StandardMaterial3D
@export var screen_mesh : MeshInstance3D
@export var color_array : Array = [Color("RED"),Color("MAGENTA"),Color("MAROON")]

@onready var scrn_text : Label3D = $Label3D
@onready var select_noise : AudioStreamPlayer = $monitor_hum_on

var trigger : bool = false
var text_pos : Vector2

var time_passed : float = 0.1

var color_target : int = 0
var audio_played_tag : bool = false

func _ready():
	select_noise.set_volume_linear(0.5)
	text_pos.x = scrn_text.position.x
	text_pos.y = scrn_text.position.y
	
func _process(delta: float) -> void:
	if trigger :
		if !audio_played_tag :
			audio_played_tag = true
			select_noise.set_pitch_scale(randf_range(0.75,1.25))
			select_noise.play()
		_do_noise(delta)
		$OmniLight3D.visible = true
		scrn_text.visible = true
		if jitter :
			var _rand = randf()*100.0
			if _rand < 7.5 :
				scrn_text.position.x = (float(randi_range(-1,1))*0.01)+ text_pos.x
				scrn_text.position.y = (float(randi_range(-1,1))*0.01)+ text_pos.y
			else :
				scrn_text.position.x = text_pos.x
				scrn_text.position.y = text_pos.y
		tv_screen_off.visible = false
		tv_screen_on.visible = true
		screen_mesh.visible = true
		trigger = false 
	else:
		audio_played_tag = false
		$OmniLight3D.visible = false
		$Label3D.visible = false
		tv_screen_off.visible = true
		tv_screen_on.visible = false
		screen_mesh.visible = false
		
func _do_noise(_delta) -> void:
		time_passed += _delta
		var sample_noise = noise.noise.get_noise_1d(time_passed)
		sample_noise = abs(sample_noise)
		omni_light.light_energy = .01 + sample_noise
		#spot_light.light_energy = .01 + sample_noise
		mat.emission_energy_multiplier = 2.0 + (8.0* sample_noise)
		screen_noise.albedo_texture.noise.offset.y = time_passed*100.0
		if time_passed > 1.0 :
			time_passed = time_passed - 1.0


func _on_timer_timeout() -> void:
	mat.albedo_color = color_array[color_target]
	mat.emission = color_array[color_target]
	omni_light.light_color = color_array[color_target]
	#spot_light.light_color = Color(color_array[color_target])
	color_target += 1
	if color_target > color_array.size()-1 :
		color_target = 0
