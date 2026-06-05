extends CharacterBody3D

@onready var visual = $Visual

const SPEED = 8.0
const JUMP_VELOCITY = 10.0
const GRAVITY = 28.0

func _physics_process(delta):

	# Gravitation
	velocity.y -= GRAVITY * delta

	# Springen
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Automatische Bewegung
	velocity.x = SPEED

	# Bewegung anwenden
	move_and_slide()

	# Rotation vom Spieler
	visual.rotate_z(8 * delta)

	# Kollisionen prüfen
	for i in get_slide_collision_count():

		var collision = get_slide_collision(i)

		if collision.get_collider().is_in_group("deadly"):
			die()


func die():

	print("TOT")

	get_tree().reload_current_scene()
