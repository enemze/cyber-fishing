extends Control

@onready var exit_button : Button = $MarginContainer/VBoxContainer/back
@onready var window_toggle : Button = $MarginContainer/VBoxContainer/fullscreen
@onready var blink_anim = $blink_sprite
@onready var audio_slider : Control = $MarginContainer/VBoxContainer/ScrollContainer/audioslidersettings
#@onready var hover_audio = $Mouse_Entered
#@onready var click_audio = $Mouse_Click

var fade_timer : float = 0.0
var fade_status : bool = false #turn this into an enum

var button_select = 0
var f_screen = false
var type_tag = 0
var misc_update : bool = false

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	blink_anim.visible = false 
	visible = false
	exit_button.button_down.connect(on_exit_pressed)
	window_toggle.button_down.connect(fullscreen_toggle)
	_resize_UI()
	set_process(false)
	
func fullscreen_toggle() -> void :
	var _win = DisplayServer.window_get_mode(0)
	if _win == 0 :
		DisplayServer.window_set_mode(4,0)
	else :
		DisplayServer.window_set_mode(0,0)
	_resize_UI()

func on_exit_pressed() -> void :
	fade_timer = 1.0
	button_select = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("escape"):
		button_select = 1
		fade_timer = 1.0
	
	if button_select != 0 :
		if fade_status || type_tag == 1:
			if button_select == 1:
				exit_options_menu.emit()
				set_process(false)
				button_select = 0
				type_tag = 0;
				
	if misc_update :
		misc_update = false
		audio_slider.set_slider_value()
				
	_fader_handling(delta)
				
func _fader_handling(delta) :
	if fade_timer > 0.0 :
		if blink_anim.frame != 0 :
			if blink_anim.is_playing() == false:
				blink_anim.play_backwards();
		else :
			fade_status = true
			fade_timer -= 1.0*delta
			fade_timer = clamp(fade_timer,0.0,999.0)
	else :
		fade_status = false
		if blink_anim.frame != blink_anim.sprite_frames.get_frame_count("default")-1 :
			if blink_anim.is_playing() == false:
				blink_anim.play();

func _resize_UI() :
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().y
	blink_anim.set_position(Vector2(viewportWidth*0.5, viewportHeight*0.5))
	blink_anim.set_scale(Vector2(scale_x, scale_y))
