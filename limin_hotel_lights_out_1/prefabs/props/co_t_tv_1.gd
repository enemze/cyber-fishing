extends Node3D

var active : bool = false
var time_passed : float = 0.0

@export var scrn_text : Label3D
@export var txt_jitter : bool = true
@export var mat: StandardMaterial3D
@export var omni_light : OmniLight3D
@export var spot_light : SpotLight3D
@export var noise : NoiseTexture3D 
@export var screen_noise : StandardMaterial3D
@export var color_array : Array = [Color("RED"),Color("MAGENTA"),Color("MAROON")]
@export var light_strength : float = 1.0
@export var light_strength_min : float = 0.01
@export var emit_strength_min : float = 2.0

var text_pos : Vector2
var turned_on : bool = true
var color_target : int = 0

func _ready() -> void:
	if scrn_text != null :
		text_pos.x = scrn_text.position.x
		text_pos.y = scrn_text.position.y

func _process(_delta) -> void:
	if active :
		turned_on = true
		time_passed += _delta
		var sample_noise = noise.noise.get_noise_1d(time_passed)
		sample_noise = abs(sample_noise)
		omni_light.light_energy = (light_strength_min + sample_noise)*light_strength
		spot_light.light_energy = (light_strength_min + sample_noise)*light_strength
		mat.emission_energy_multiplier = (emit_strength_min + (8.0* sample_noise))*light_strength
		screen_noise.albedo_texture.noise.offset.y = time_passed*100.0
		if time_passed > 1.0 :
			time_passed = time_passed - 1.0
		
		if scrn_text != null :
			if txt_jitter :
				var _rand = randf()*100.0
				if _rand < 7.5 :
					scrn_text.position.x = (float(randi_range(-1,1))*0.01)+ text_pos.x
					scrn_text.position.y = (float(randi_range(-1,1))*0.01)+ text_pos.y
				else :
					scrn_text.position.x = text_pos.x
					scrn_text.position.y = text_pos.y

		
func toggle_vis_effects(_off_or_on : bool) -> void:
	if !_off_or_on : #off
			$"TV1-Screen".visible = false
			$"TV1-Screen2".visible = false
			$"TV1-Screen3".visible = true
			$OmniLight3D.visible = false
			$SpotLight3D.visible = false
			if scrn_text != null :
				scrn_text.visible = false
	else: #on
			$"TV1-Screen".visible = true
			$"TV1-Screen2".visible = true
			$"TV1-Screen3".visible = false
			$OmniLight3D.visible = true
			$SpotLight3D.visible = true
			if scrn_text != null :
				scrn_text.visible = true
	
		
func _on_timer_timeout() -> void:
	if active:
		if $AudioStreamPlayer3D.is_playing() == false :
			$AudioStreamPlayer3D.play()
		mat.albedo_color = color_array[color_target]
		mat.emission = color_array[color_target]
		omni_light.light_color = color_array[color_target]
		spot_light.light_color = color_array[color_target]
		color_target += 1
		if color_target > color_array.size()-1 :
			color_target = 0
	else:
		if $AudioStreamPlayer3D.is_playing() :
			$AudioStreamPlayer3D.stop()
