extends Node3D


#when function triggered, take value, and trigger the UPDATE for all objects in that group
@export var group_0 : Node3D
@export var group_1 : Node3D
@export var group_2 : Node3D
@export var group_3 : Node3D

var update_group_array = []
var on_off_check = []

var last_update_group : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_group_array = [group_0,group_1,group_2,group_3]
	for n in update_group_array.size():
		var _list = update_group_array[n].get_children()
		for m in _list.size():
			if _list[m].is_in_group("on_off_check") :
				on_off_check.push_back(_list[m])
	print(str(on_off_check))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_update_trigger_type_a_update_side_state(value: Variant) -> void:
	if value != last_update_group :
		_update_all(value)
		last_update_group = value

func _update_all(int_value) -> void:
	#get children
	#run update on all children 
	print("updating on_off groups")
	var _list = update_group_array[int_value].get_children()
	for n in _list.size() :
		if _list[n].is_in_group("room_update") :
			_list[n]._update()
	
	#check if half of lights are active; if so, release the anomaly :V 
	var _size = on_off_check.size()
	var _check = 0
	for n in _size :
		if on_off_check[n].on_off_check == true :
			_check += 1
	if float(_check) > float(_size) * 0.4 :
		$"../hadex_holder/hadex_anomaly".active = true
		
