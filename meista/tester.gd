extends CharacterBody3D

@onready var visual = $Visual
@onready var score_label = $"../CanvasLayer/con/ScoreLabel"
@onready var highscore_label = $"../CanvasLayer/con/HighscoreLabel"
@onready var spawner = $"../PlatformSpawner"

const JUMP_VELOCITY = 20.0
const GRAVITY = 20.0

var jumps_left = 4

var score = 0
var highscore = 0

var spawn_position : Vector3

var dead = false

var spin_speed = 0.0
var stuck = false


func _ready():

	spawn_position = global_position

	score_label.text = "Score: 0"
	highscore_label.text = "Highscore: 0"


func _physics_process(delta):

	velocity.y -= GRAVITY * delta
	if is_on_floor():
		jumps_left = 4
		velocity.z = lerp(velocity.z, 0.0, 0.2)
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		velocity.z -= 4.0
		spin_speed = 6.0
		stuck = false

		jumps_left -= 1

	move_and_slide()

	visual.rotate_z(spin_speed * delta)

	if is_on_floor() and not stuck:
		var angle = fmod(abs(rad_to_deg(visual.rotation.z)), 360.0)
		var valid_landing = false

		if angle > 60 and angle < 120:
			valid_landing = true

		if angle > 240 and angle < 300:
			valid_landing = true
		if valid_landing:
			stuck = true
			velocity = Vector3.ZERO
			spin_speed = 0.0
		else:
			velocity.y = .0
			spin_speed *= 1.8
	score -= int(global_position.z)
	if score < 0:
		score = 0

	score_label.text = "Score: " + str(score)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("deadly"):
			die()


func die():

	if dead:
		return

	dead = true

	if score > highscore:
		highscore = score

	highscore_label.text = "Highscore: " + str(highscore)

	score = 0
	score_label.text = "Score: 0"

	global_position = spawn_position

	velocity = Vector3.ZERO

	jumps_left = 2

	spin_speed = 0.0
	stuck = false

	if spawner:
		spawner.reset_world()

	await get_tree().create_timer(0.2).timeout

	dead = false
