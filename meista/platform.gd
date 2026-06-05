extends Node3D

@export var move_speed = 2.0
@export var move_range = 2.0

var start_pos

func _ready():
	start_pos = position

#func _process(delta):
	#position.z = start_pos.z + sin(Time.get_time_dict_from_system()["second"] + position.x) * move_range
