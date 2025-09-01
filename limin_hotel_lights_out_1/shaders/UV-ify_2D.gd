extends MeshInstance3D

var BLUEPRINT_SHADER = preload("res://shaders/UV_ghost_shader_2D.gdshader")

#NOTE
#INSTRUCTIONS:
# set the Surface Material Override to whatever Texture you want 
# you can either click & drag the texture into the SMO slot 
# or apply a Material & change the albedo's texture there

#NOTE
# IF STILL VISIBLE
# if the object is still lit in the scene w/out the UV light being on it
# make sure any nearby Lights have the "2" slot on the Cull Mask set un-checked 

#NOTE
# to apply this MANUALLY
# 1. goto to GeometryInstance3D tab 
# 2. create a new shader material in the material override slot
# 3. apply UV_ghost_shader_2D to that tab 
# 4. in the shader parameters, click & drag whatever texture you want to see in game into the "Tex" slot
# 5. set "cast shadow" to off 
# 6. goto the VisualInstance3D tab 
# 7. uncheck the "1" box
# 8. check the "2' box
# 9s. done! 

func _ready() -> void:
	var _grab_text : StandardMaterial3D = get_surface_override_material(0)
	var _texture = _grab_text.albedo_texture
	var override_material = ShaderMaterial.new()
	override_material.shader = BLUEPRINT_SHADER
	override_material.set_shader_parameter("tex",_texture)

	set_surface_override_material(0, override_material)
	
	cast_shadow = 0

	set_layer_mask_value(1,false)
	set_layer_mask_value(2,true)
