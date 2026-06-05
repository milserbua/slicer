extends Node3D

@export var platform_scene: PackedScene
@export var player: Node3D

var spawn_z = 0.0
var spawn_distance = 10.0
var difficulty_multiplier = 1.0
var platforms_spawned = 0

func _ready():
	for i in range(20):
		spawn_platform()

func _process(delta):
	# Spawn platforms ahead of player with difficulty scaling
	if player.position.z < spawn_z + 40:
		spawn_platform()
	
	# Progressive difficulty increase
	difficulty_multiplier = 1.0 + (platforms_spawned / 50.0) * 0.3

func spawn_platform():
	var platform = platform_scene.instantiate()
	
	# Randomize X position based on difficulty
	var x_variation = randf_range(-1.5, 1.5) * difficulty_multiplier
	
	platform.position = Vector3(
		x_variation,
		randf_range(-0.8, 1.2),
		spawn_z
	)
	
	add_child(platform)
	spawn_z -= spawn_distance
	platforms_spawned += 1
	
func reset_world():
	for child in get_children():
		child.queue_free()
	spawn_z = 0.0
	platforms_spawned = 0
	difficulty_multiplier = 1.0
	for i in range(20):
		spawn_platform()
