extends Node3D

@export var platform_scene: PackedScene
@export var player: Node3D

var spawn_z = 0.0
var spawn_distance = 10.0

func _ready():
	for i in range(20):
		spawn_platform()

func _process(delta):

	# nur nach vorne spawnen, nicht bei Stillstand spammen
	if player.position.z < spawn_z + 40:
		spawn_platform()

func spawn_platform():
	var platform = platform_scene.instantiate()

	# FIX: nur Z basiert, kein Chaos
	platform.position = Vector3(
		0.0, #X
		randf_range(-1.0, 1.0),  # Y Variation
		spawn_z
	)
	add_child(platform)
	spawn_z -= spawn_distance
	
func reset_world():
	for child in get_children():
		child.queue_free()
		spawn_z = 0.0
	for i in range(20):
		spawn_platform()
