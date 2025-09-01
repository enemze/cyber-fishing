extends ColorRect

@export var fade_speed : float = 0.6

var fader_alpha : float = 2.0 #set this to 2.0 once we're done debugging 
var fade_dir : float = -1.0 #set this to -1.0 once we're done debugging 
var fade_in_out : int = 0
var fade_timer : float = 0.5

signal fade_state(in_or_out)
signal sig_fade_clear

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	resize_UI()
	
func _physics_process(delta: float) -> void:
	
	_fade_handler(delta)
	
func fade_active(time : float ) -> void : 
	fade_timer = time
	
func _fade_handler(delta) -> void:
	if(fade_timer > 0.0):
		fader_alpha += (fade_speed * delta) #fade to black
		fade_timer -= (fade_speed*delta)
	else :
		if(fader_alpha == 1.0):
			sig_fade_clear.emit()
		fader_alpha -= (fade_speed * delta)
		
	fader_alpha = clamp(fader_alpha,0.0,1.0);
	fade_timer = clamp(fade_timer,0.0,999.0);
	if(fader_alpha == 1.0):
		fade_state.emit(0)
	modulate.a = fader_alpha

func resize_UI() -> void:
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	set_position(Vector2(0.0, 0.0))
	set_size(Vector2(viewportWidth, viewportHeight))
