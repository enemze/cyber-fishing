extends SubViewportContainer

@onready var text_entry : TextEdit = $TextEntryA/TextEdit
@onready var text_display : Control = $TextEntryA
@onready var player : Node3D = $SubViewport/Node3D/main/player_TPS
#@onready var camera : Node3D = $SubViewport/Node3D/main/CameraTps
#@onready var cam_text : Label3D = $"SubViewport/Node3D/main/CameraTps/Camera Target/Camera3D/Label3D"
var entry_toggle = false
var _reparent_toggle = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#cam_text.visible = false
	text_display.visible = false
	grab_focus()
	#cam_text.text = ""
	player.viewport_shader = $SubViewport


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#.text
	#"VN_TextboxLayer/Anchor/AnimationParent/Sizer/DialogTextPanel/DialogicNode_DialogText"
	
	#if _reparent_toggle :
		#var _check = get_tree().root.get_node("Dialogic")
		#print(_check)
		#_check.reparent($SubViewport,false)
		#_reparent_toggle = false
	
	#cam_text.text = text_entry.text
	if Input.is_action_just_pressed("open_text_entry"):
		if entry_toggle :
			player.set_process(true)
			player.set_physics_process(true)
			text_display.visible = false
			#cam_text.visible = false
			grab_focus()
			entry_toggle = false
		else:	
			player.set_process(false)
			player.set_physics_process(false)
			text_display.visible = true
			#cam_text.visible = true
			text_entry.grab_focus()
			entry_toggle = true
