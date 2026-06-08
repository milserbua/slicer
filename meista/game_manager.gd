extends Node3D

class_name GameManager

@onready var spawner = $Platformspawner
@onready var score_label = $CanvasLayer/con/ScoreLabel
@onready var highscore_label = $CanvasLayer/con/HighscoreLabel
@onready var level_label = $CanvasLayer/con/LevelLabel
@onready var coins_label = $CanvasLayer/con/CoinsLabel

enum Difficulty { EASY, NORMAL, HARD }

var current_difficulty = Difficulty.NORMAL
var shop_manager: Node
var audio_manager: Node

var difficulty_settings = {
	Difficulty.EASY: {
		"platform_width": 1.2,
		"platform_spacing": 8.0,
		"spawn_distance": 10.0
	},
	Difficulty.NORMAL: {
		"platform_width": 0.9,
		"platform_spacing": 10.0,
		"spawn_distance": 10.0
	},
	Difficulty.HARD: {
		"platform_width": 0.6,
		"platform_spacing": 12.0,
		"spawn_distance": 10.0
	}
}

var game_state = "playing"
var pause_menu_shown = false

func _ready():
	add_to_group("game_manager")
	
	# Get existing manager nodes from scene
	shop_manager = get_node_or_null("ShopManager")
	audio_manager = get_node_or_null("AudioManager")
	
	# Ensure managers are in groups
	if shop_manager:
		shop_manager.add_to_group("shop_manager")
	
	if audio_manager:
		audio_manager.add_to_group("audio_manager")
	
	apply_difficulty_settings()
	update_ui()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
	
	if game_state == "playing":
		update_ui()

func apply_difficulty_settings():
	var settings = difficulty_settings[current_difficulty]
	if spawner:
		spawner.spawn_distance = settings["platform_spacing"]

func update_ui():
	var difficulty_name = Difficulty.keys()[current_difficulty]
	if level_label:
		level_label.text = "Level: " + difficulty_name
	
	if highscore_label:
		highscore_label.text = "Highscore: 0"
	
	if shop_manager and coins_label:
		coins_label.text = "💰 " + str(shop_manager.player_coins)

func toggle_pause():
	pause_menu_shown = !pause_menu_shown
	if pause_menu_shown:
		game_state = "paused"
		get_tree().paused = true
	else:
		game_state = "playing"
		get_tree().paused = false

func set_difficulty(difficulty_level: int):
	current_difficulty = difficulty_level
	apply_difficulty_settings()
	update_ui()

func save_score(score: int, platforms: int):
	print("Score saved: %d (Platforms: %d)" % [score, platforms])
