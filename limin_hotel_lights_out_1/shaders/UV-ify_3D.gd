extends MeshInstance3D

var BLUEPRINT_SHADER = preload("res://shaders/UV_ghost_shader_3D.gdshader")

#NOTE
#INSTRUCTIONS:
# none. just apply the script to the Mesh! 

#NOTE
# IF STILL VISIBLE
# if the object is still lit in the scene w/out the UV light being on it
# make sure any nearby Lights have the "2" slot on the Cull Mask set un-checked 

#NOTE
# to apply this MANUALLY
# 1. goto to GeometryInstance3D tab 
# 2. create a new shader material in the material override slot
# 3. apply UV_ghost_shader_3D to that tab 
# 4. set "cast shadow" to off 
# 5. goto the VisualInstance3D tab 
# 6. uncheck the "1" box
# 7. check the "2' box
# 8. done! 

func _ready() -> void:
	var override_material = ShaderMaterial.new()
	override_material.shader = BLUEPRINT_SHADER
	#mesh.surface_set_material(0,override_material)
	set_surface_override_material(0, override_material)
	
	#GeometryInstance3D.ShadowCastingSetting = false
	cast_shadow = 0

	set_layer_mask_value(1,false)
	set_layer_mask_value(2,true)
