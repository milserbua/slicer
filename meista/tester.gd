extends CharacterBody3D

@onready var visual = $Visual
@onready var score_label = $"../CanvasLayer/con/ScoreLabel"
@onready var highscore_label = $"../CanvasLayer/con/HighscoreLabel"
@onready var coins_label = $"../CanvasLayer/con/CoinsLabel"
@onready var spawner = $"../Platformspawner"

const JUMP_VELOCITY = 20.0
const GRAVITY = 20.0
const JUMP_DAMPING = 0.15
const MIN_SPIN_SPEED = 0.5
const COINS_PER_PLATFORM = 5
const SCORE_MULTIPLIER = 10

var jumps_left = 4
var score = 0
var highscore = 0
var coins_earned = 0
var spawn_position : Vector3
var dead = false
var spin_speed = 0.0
var stuck = false
var platforms_passed = 0
var combo = 0
var combo_multiplier = 1.0

var shop_manager: Node
var audio_manager: Node

func _ready():
	spawn_position = global_position
	score_label.text = "Score: 0"
	highscore_label.text = "Highscore: 0"
	coins_label.text = "Coins: 0"
	
	shop_manager = get_tree().get_first_node_in_group("shop_manager")
	audio_manager = get_tree().get_first_node_in_group("audio_manager")
	
	# Apply current knife skin
	if shop_manager:
		apply_knife_skin()

func apply_knife_skin():
	if not shop_manager:
		return
	
	var skin_data = shop_manager.get_current_skin_data()
	if skin_data and visual:
		var knife = visual.get_node_or_null("messer")
		if knife:
			# Find MeshInstance3D nodes and update material
			for child in knife.get_children():
				if child is MeshInstance3D:
					var mat = StandardMaterial3D.new()
					mat.albedo_color = skin_data["color"]
					mat.metallic = 1.0
					child.set_surface_override_material(0, mat)

func _physics_process(delta):
	# Gravity
	velocity.y -= GRAVITY * delta
	
	# Ground check and reset
	if is_on_floor():
		jumps_left = 4
		velocity.z = lerp(velocity.z, 0.0, JUMP_DAMPING)
	
	# Jump input
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		velocity.z -= 4.0
		spin_speed = 6.0
		stuck = false
		jumps_left -= 1
		play_jump_sound()
	
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

		if (angle > 60 and angle < 120) or (angle > 240 and angle < 300):
			valid_landing = true

		if valid_landing:
			stuck = true
			velocity = Vector3.ZERO
			spin_speed = 0.0
			platforms_passed += 1
			combo += 1
			combo_multiplier = 1.0 + (combo * 0.1)  # +10% per combo
			
			# Calculate score with combo multiplier
			var base_score = SCORE_MULTIPLIER * combo_multiplier
			score += int(base_score)
			
			# Earn coins
			var coins = int(COINS_PER_PLATFORM * combo_multiplier)
			coins_earned += coins
			
			play_cut_sound()
			create_cut_effect()
		else:
			velocity.y = 0.0
			spin_speed *= 1.8
			combo = 0
			combo_multiplier = 1.0

	score_label.text = "Score: " + str(score) + " (x%.1f)" % combo_multiplier
	if coins_label:
		coins_label.text = "Coins: " + str(coins_earned)
	
	# Collision detection
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("deadly"):
			die()

func play_jump_sound():
	if audio_manager and audio_manager.has_method("play_sound"):
		audio_manager.play_sound("jump")

func play_cut_sound():
	if audio_manager and audio_manager.has_method("play_sound"):
		audio_manager.play_sound("cut", 0.2)

func create_cut_effect():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(visual, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
	tween.tween_property(visual, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func die():
	if dead:
		return

	dead = true
	
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.save_score(score, platforms_passed)
	
	# Add coins to shop manager
	if shop_manager:
		shop_manager.add_coins(coins_earned)

	if score > highscore:
		highscore = score

	highscore_label.text = "Highscore: " + str(highscore)

	score = 0
	coins_earned = 0
	platforms_passed = 0
	combo = 0
	combo_multiplier = 1.0
	score_label.text = "Score: 0"
	coins_label.text = "Coins: 0"

	global_position = spawn_position
	velocity = Vector3.ZERO
	jumps_left = 4
	spin_speed = 0.0
	stuck = false

	if spawner:
		spawner.reset_world()

	await get_tree().create_timer(0.2).timeout

	dead = false
