extends Control

var state : int = 0



@onready var blink_anim : AnimatedSprite2D = $"../blink_sprite"
@onready var start_level = preload("res://MainRenderContainer.tscn") as PackedScene 
@onready var options_menu = $"../options_pause_menu"

var blink_frames_max : int = 0

func _ready() -> void :
	$"../ColorRect".visible = false
	options_menu.visible = false
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	blink_anim.visible = true
	_resize_UI()
	blink_anim.set_frame_and_progress(0,0.0)
	blink_anim.play()
	blink_frames_max = blink_anim.sprite_frames.get_frame_count("default") - 1
	
	
func _process(delta) -> void :
	
	match state :
		0: #basic state. do nothing.
			pass
		1: #start game
			_start_game()
		2: #quit game
			_quit_game()
		3: #start options menu
			if blink_anim.frame == 0 :
				state = 4
			else :
				if !blink_anim.is_playing() :
					blink_anim.play_backwards()
		4: #swap to options menu
			options_menu.misc_update = true
			vis_swap_main()
			blink_anim.visible = false
			options_menu.visible = true
			options_menu.set_process(true)
			state = 5
		5 : #in options menu 
			pass
	
#maintenance functions 
			
func _resize_UI() -> void:
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().y
	blink_anim.set_position(Vector2(viewportWidth*0.5, viewportHeight*0.5))
	blink_anim.set_scale(Vector2(scale_x, scale_y))

#buttons 

func _on_start_pressed() -> void:
	if state == 0:
		state = 1
		
func _on_options_pressed() -> void:
	if state == 0:
		state = 3

func _on_quit_pressed() -> void:
	if state == 0:
		state = 2
		
#button functions 
	
func _start_game() -> void:
	if blink_anim.frame == 0.0 :
		get_tree().change_scene_to_packed(start_level)
	else :
		if !blink_anim.is_playing() :
			blink_anim.play_backwards()
			
func _quit_game() -> void:
	if blink_anim.frame == 0.0 :
		get_tree().quit()
	else :
		if !blink_anim.is_playing() :
			blink_anim.play_backwards()
	
func on_exit_options_menu() -> void:
	vis_swap_main()
	#store saved date stuff & save game 
	#_update_save_file()
	#_save_game()
	options_menu.visible = false
	blink_anim.visible = true
	blink_anim.set_frame_and_progress(0,0.0)
	blink_anim.play()
	_resize_UI()
	
#this is garbage but I don't have time to fix it 
func vis_swap_main() -> void:
	$HBoxContainer.visible = !$HBoxContainer.visible
	options_menu.blink_anim.visible = !options_menu.blink_anim.visible
	#options_menu.fade_timer = 1.0

func _on_options_pause_menu_exit_options_menu() -> void:
	print("exit options menu")
	state = 0
