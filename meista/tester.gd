extends CharacterBody3D

@onready var visual = $Visual
@onready var score_label = $"../CanvasLayer/con/ScoreLabel"
@onready var highscore_label = $"../CanvasLayer/con/HighscoreLabel"
@onready var spawner = $"../Platformspawner"

const JUMP_VELOCITY = 20.0
const GRAVITY = 20.0
const JUMP_DAMPING = 0.15
const MIN_SPIN_SPEED = 0.5

var jumps_left = 4
var score = 0
var highscore = 0
var spawn_position : Vector3
var dead = false
var spin_speed = 0.0
var stuck = false
var platforms_passed = 0


func _ready():
	spawn_position = global_position
	score_label.text = "Score: 0"
	highscore_label.text = "Highscore: 0"


func _physics_process(delta):
	# Gravity
	velocity.y -= GRAVITY * delta
	
	# Ground check and reset
	if is_on_floor():
		jumps_left = 4
		velocity.z = lerp(velocity.z, 0.0, JUMP_DAMPING)
	
	# Jump input with double jump mechanic
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		velocity.z -= 4.0
		spin_speed = 6.0
		stuck = false
		jumps_left -= 1
	
	# Smooth spin decay
	if is_on_floor() and stuck:
		spin_speed = lerp(spin_speed, 0.0, 0.1)
	else:
		spin_speed = max(spin_speed - 0.5 * delta, MIN_SPIN_SPEED)

	move_and_slide()

	# Smooth visual rotation
	visual.rotate_z(spin_speed * delta)

	# Landing detection
	if is_on_floor() and not stuck:
		var angle = fmod(abs(rad_to_deg(visual.rotation.z)), 360.0)
		var valid_landing = false

		# Valid landing zones (horizontal blade)
		if (angle > 60 and angle < 120) or (angle > 240 and angle < 300):
			valid_landing = true

		if valid_landing:
			stuck = true
			velocity = Vector3.ZERO
			spin_speed = 0.0
			platforms_passed += 1
			score = platforms_passed * 10
		else:
			velocity.y = 0.0
			spin_speed *= 1.8

	score_label.text = "Score: " + str(score)
	
	# Collision detection
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
	platforms_passed = 0
	score_label.text = "Score: 0"

	global_position = spawn_position
	velocity = Vector3.ZERO
	jumps_left = 4
	spin_speed = 0.0
	stuck = false

	if spawner:
		spawner.reset_world()

	await get_tree().create_timer(0.2).timeout

	dead = false
