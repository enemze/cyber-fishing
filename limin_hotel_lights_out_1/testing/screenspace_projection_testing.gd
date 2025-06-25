extends Node3D

@onready var mesh : MeshInstance3D = $StaticBody3D/MeshInstance3D
@onready var target : StaticBody3D = $StaticBody3D
@onready var camera : Camera3D = $Camera3D
@onready var aim_ray : RayCast3D = $RayCast3D
var collider_array : Array
var screen_array : Array

func _ready():
	collider_array = [
		$StaticBody3D,
		$StaticBody3D2,
		$StaticBody3D3
		]
	screen_array = [
		[$"TV12/TV1-Screen",$"TV12/TV1-Screen2"],
		[$"TV22/TV2-Screen",$"TV22/TV2-Screen2"],
		[$"TV32/TV3-Screen",$"TV32/TV3-Screen2"]
		]
	
func _process(delta: float) -> void:
		var _camera = get_viewport().get_camera_3d()
		var _viewport = get_viewport().size
		var _ray_origin = _camera.project_ray_origin(_viewport/2)
		var _spread = get_viewport().get_mouse_position()
		#windowed
		#_spread.x -= 320.0*4.0
		#_spread.y -= 160.0*4.0
		#fullscreen; we'll need to get these values from base screen 
		#size / actual screen size based on the formula we use for the 
		#blink sprite 
		var viewportWidth = get_viewport().size.x
		var viewportHeight = get_viewport().size.y
		var scale_x = viewportWidth / 640.0
		var scale_y = viewportHeight / 320.0
		print(scale_x)
		print(scale_y)
		_spread.x -= 320.0*scale_x
		_spread.y -= 160.0*scale_y
		
		var _range = 50.0
		var _ray_end = (_ray_origin + camera.project_ray_normal((_viewport/2)+Vector2i(_spread))*_range)
			
		var _new_intersection = PhysicsRayQueryParameters3D.create(_ray_origin,_ray_end)
		_new_intersection.set_collision_mask(0b00000000_00000000_00000000_00000001)
		
		var _intersection = get_world_3d().direct_space_state.intersect_ray(_new_intersection)
		
		var _collision
			
		if not _intersection.is_empty() :
			_collision = [_intersection.collider,_intersection.position]
		else :
			_collision = [null, _ray_end]	
			
		aim_ray.look_at(_collision[1])
		
		var _toggle : int = -1
			
		for n in collider_array.size() :
			if _collision[0] == collider_array[n] :
				_toggle = n
			
			screen_array[n][0].visible = true
			screen_array[n][1].visible = false
			
				
		if _toggle != -1 :
			screen_array[_toggle][0].visible = false
			screen_array[_toggle][1].visible = true
			
		
