extends Node3D

#just include the second trigger HERE and then make this object UNIQUE and move it 

@export var world : Node3D
@export var light : Node3D
@export var sub_light : OmniLight3D
@export var COT_TV : Node3D

var breaker = false
var trigger = false
var emit = false
var on_off_check = false
var reveals_position_array : Array = []
var event_toggle = true
var lights_off : Array = []

func _ready() :
	sub_light.visible = false
	light.visible = false
	var _reveals = $reveals.get_children()
	for n in _reveals.size(): 
		reveals_position_array.append(_reveals[n].global_position)
		_reveals[n].global_position.y = -200
	lights_off = [
		$lights/flour_light_base_9,
		$lights/flour_light_base_11,
		$lights/flour_light_base_21,
		$lights/flour_light_base_15,
		$lights/flour_light_base_20,
		$lights/flour_light_base_14
		]
	COT_TV.toggle_vis_effects(false)
	COT_TV.active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if breaker: 
		if trigger :
			if light.visible == false :
				sub_light.visible = true
				on_off_check = true
				remove_from_group("show_interact_text")
				$AudioStreamPlayer3D.play()
				light.func_on_off()
				emit = true
				trigger = false
				var _reveals = $reveals.get_children()
				for n in _reveals.size(): 
					_reveals[n].global_position = reveals_position_array[n]
		if event_toggle :
			for n in lights_off.size():
				lights_off[n].visible = false
				lights_off[n].audio.stop()
			COT_TV.toggle_vis_effects(true)
			COT_TV.active = true
			event_toggle = false
	if 	$audio_air_cond.is_playing() :
		$audio_air_cond.volume_linear = lerp($audio_air_cond.volume_linear,0.0,0.05)
		$audio_water_heater.volume_linear = lerp($audio_water_heater.volume_linear,0.0,0.05)
		if $audio_air_cond.volume_linear == 0:
			$audio_air_cond.stop()
			$audio_water_heater.stop()
	else :
		if trigger :
			$AudioStreamPlayer3D2.play()
			trigger = false
	
func _on_timer_timeout() -> void:	
		if world.player_location == 3:
			if !breaker :
				$audio_air_cond.play()
				$audio_water_heater.play()
			if !event_toggle :
				COT_TV.toggle_vis_effects(true)
				COT_TV.active = true
		else :
			$audio_air_cond.stop()
			$audio_water_heater.stop()
			if !event_toggle :
				COT_TV.toggle_vis_effects(false)
				COT_TV.active = false
