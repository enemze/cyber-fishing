extends MeshInstance3D

@export var blades : MeshInstance3D
@export var speed : float = 1.0

func _process(delta):
	
	blades.rotation.z += speed*delta
	if blades.rotation.z > 360.0 :
		blades.rotation.z -= 360.0
