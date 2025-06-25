extends Node3D

# Export variables for the inspector
@export var bounding_box_mesh : MeshInstance3D  # Reference to the MeshInstance3D defining the bounding box
@export var speed : float = 5.0  # Movement speed
@export var animation_name : String = "ArmatureAction"  # Name of the animation to play

# Internal variables
var velocity : Vector3 = Vector3.ZERO
var bounding_box : AABB
var animation_player : AnimationPlayer

func _ready() -> void:
	# Validate the bounding box mesh
	if not bounding_box_mesh:
		push_error("Bounding box MeshInstance3D not assigned!")
		set_physics_process(false)
		return
	
	# Initialize the bounding box from the MeshInstance3D
	update_bounding_box()
	
	# Get the AnimationPlayer (assumes it's a child node)
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		if animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
		else:
			push_error("Animation '%s' not found!" % animation_name)
	else:
		push_error("AnimationPlayer node not found!")
	
	# Initialize random velocity
	velocity = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() * speed

func _physics_process(delta: float) -> void:
	# Update bounding box in case the MeshInstance3D moves
	update_bounding_box()
	
	# Update position based on velocity
	var new_position = position + velocity * delta
	
	# Check boundaries and reflect velocity if hitting a wall
	var min_bound = bounding_box.position
	var max_bound = bounding_box.end
	
	if new_position.x < min_bound.x:
		new_position.x = min_bound.x
		velocity.x = -velocity.x
	elif new_position.x > max_bound.x:
		new_position.x = max_bound.x
		velocity.x = -velocity.x
	
	if new_position.y < min_bound.y:
		new_position.y = min_bound.y
		velocity.y = -velocity.y
	elif new_position.y > max_bound.y:
		new_position.y = max_bound.y
		velocity.y = -velocity.y
	
	if new_position.z < min_bound.z:
		new_position.z = min_bound.z
		velocity.z = -velocity.z
	elif new_position.z > max_bound.z:
		new_position.z = max_bound.z
		velocity.z = -velocity.z
	
	# Apply the new position
	position = new_position
	
	# Occasionally change direction for organic movement
	if randf() < 0.01:  # 1% chance per frame
		velocity = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized() * speed

func update_bounding_box() -> void:
	# Get the AABB from the MeshInstance3D's mesh, transformed to world space
	if bounding_box_mesh and bounding_box_mesh.mesh:
		var local_aabb = bounding_box_mesh.mesh.get_aabb()
		var global_transform = bounding_box_mesh.global_transform
		bounding_box = local_aabb.transformed(global_transform)
	else:
		bounding_box = AABB(position, Vector3(1.0, 1.0, 1.0))  # Fallback AABB
