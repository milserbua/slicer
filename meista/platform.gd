extends Node3D

@export var move_speed = 2.0
@export var move_range = 2.0
@export var oscillate = false

var start_pos
var time_offset = 0.0

func _ready():
	start_pos = position
	time_offset = randf_range(0.0, 2.0 * PI)

func _process(delta):
	if oscillate:
		# Subtle platform movement for added challenge
		position.x = start_pos.x + sin(Time.get_ticks_msec() / 1000.0 + time_offset) * move_range
		position.y = start_pos.y + cos(Time.get_ticks_msec() / 1500.0 + time_offset) * (move_range * 0.5)
