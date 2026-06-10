extends CharacterBody3D

@onready var visual = $Visual
@onready var highscore_label = $"../CanvasLayer/con/HighscoreLabel"
@onready var coins_label = $"../CanvasLayer/con/CoinsLabel"
@onready var distance_label = $"../CanvasLayer/con/DistanceLabel"
@onready var spawner = $"../Platformspawner"

const JUMP_VELOCITY = 20.0
const GRAVITY = 20.0
const JUMP_DAMPING = 0.15
const MIN_SPIN_SPEED = 0.5
const COINS_PER_DISTANCE = 1.0

var jumps_left = 4
var coins_earned = 0
var spawn_position : Vector3
var dead = false
var spin_speed = 0.0
var stuck = false
var platforms_passed = 0
var combo = 0
var combo_multiplier = 1.0
var highest_z = 0.0
var best_distance = 0.0

var shop_manager: Node
var audio_manager: Node

func _ready():
	spawn_position = global_position
	highest_z = 0.0
	best_distance = 0.0
	highscore_label.text = "Best: 0m"
	coins_label.text = "💰 0"
	distance_label.text = "📍 0m"

	await get_tree().process_frame
	shop_manager = get_tree().get_first_node_in_group("shop_manager")
	print("FOUND SHOP MANAGER:", shop_manager)
	audio_manager = get_tree().get_first_node_in_group("audio_manager")

	if shop_manager:
		apply_knife_skin()

func apply_knife_skin():
	if not shop_manager:
		return

	var skin_data = shop_manager.get_current_skin_data()
	if skin_data and visual:
		var knife = visual.get_node_or_null("messer")
		if knife:
			for child in knife.get_children():
				if child is MeshInstance3D:
					var mat = StandardMaterial3D.new()
					mat.albedo_color = skin_data["color"]
					mat.metallic = 1.0
					child.set_surface_override_material(0, mat)

func _physics_process(delta):
	velocity.y -= GRAVITY * delta
	if is_on_floor():
		jumps_left = 4
		velocity.z = lerp(velocity.z, 0.0, JUMP_DAMPING)

	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		velocity.z -= 4.0
		spin_speed = 6.0
		stuck = false
		jumps_left -= 1
		play_jump_sound()

	if is_on_floor() and stuck:
		spin_speed = lerp(spin_speed, 0.0, 0.1)
	else:
		spin_speed = max(spin_speed - 0.5 * delta, MIN_SPIN_SPEED)

	move_and_slide()

	visual.rotate_z(spin_speed * delta)

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
			combo_multiplier = 1.0 + (combo * 0.15)

			var z_distance = abs(spawn_position.z - global_position.z)

			if z_distance > highest_z:
				var distance_gained = z_distance - highest_z
				highest_z = z_distance
				
				var coins = 10* max(1, int(distance_gained * COINS_PER_DISTANCE * combo_multiplier))
				print("distance=", distance_gained, " coins=", coins)
				coins_earned 	+= coins
				if coins > 0:
					coins_earned += coins
					if shop_manager:
						print("shop_manager=", shop_manager)
						shop_manager.add_coins(coins)

			play_cut_sound()
			create_cut_effect()
		else:
			velocity.z = 0.0
			spin_speed *= 1.8
			combo = 0
			combo_multiplier = 1.0

	update_ui()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("deadly"):
			die()

func update_ui():
	var current_distance = abs(spawn_position.z - global_position.z)
	distance_label.text = "📍 %.1fm" % current_distance

	if shop_manager:
		coins_label.text = "💰 " + str(shop_manager.player_coins)
	else:
		coins_label.text = "💰 0"

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

func _on_area_3d_body_entered(body):
	if body.is_in_group("sliceable"):
		body.slice()

func die():
	if dead:
		return
	dead = true

	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.save_distance(platforms_passed, int(abs(spawn_position.y - global_position.y)))

	var current_distance = int(abs(spawn_position.z - global_position.z))
	if current_distance > best_distance:
		best_distance = current_distance

	highscore_label.text = "Best: %dm" % best_distance

	coins_earned = 0
	platforms_passed = 0
	combo = 0
	combo_multiplier = 1.0
	highest_z = spawn_position.z

	global_position = spawn_position
	velocity = Vector3.ZERO
	jumps_left = 4
	spin_speed = 0.0
	stuck = false

	if spawner:
		spawner.reset_world()

	await get_tree().create_timer(0.2).timeout

	dead = false
