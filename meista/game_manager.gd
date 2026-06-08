extends Node3D

class_name GameManager

@onready var player = $Tester
@onready var score_label = $CanvasLayer/con/ScoreLabel
@onready var highscore_label = $CanvasLayer/con/HighscoreLabel
@onready var level_label = $CanvasLayer/con/LevelLabel
@onready var coins_label = $CanvasLayer/con/CoinsLabel
@onready var spawner = $Platformspawner

enum Difficulty { EASY, NORMAL, HARD }

var current_difficulty = Difficulty.NORMAL
var save_manager: SaveManager
var shop_manager: ShopManager
var audio_manager: AudioManager
var input_manager: Node

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
	
	# Initialize managers
	save_manager = SaveManager.new()
	add_child(save_manager)
	
	shop_manager = ShopManager.new()
	add_child(shop_manager)
	add_to_group("shop_manager", shop_manager)
	
	audio_manager = AudioManager.new()
	add_child(audio_manager)
	
	input_manager = load("res://meista/input_manager.gd").new() if ResourceLoader.exists("res://meista/input_manager.gd") else null
	if input_manager:
		add_child(input_manager)
	
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
		spawner.platform_width = settings["platform_width"]
		spawner.spawn_distance = settings["platform_spacing"]

func update_ui():
	var difficulty_name = Difficulty.keys()[current_difficulty]
	if level_label:
		level_label.text = "Level: " + difficulty_name
	
	if save_manager and highscore_label:
		var difficulty_str = Difficulty.keys()[current_difficulty].to_lower()
		var hs = save_manager.get_highscore(difficulty_str)
		highscore_label.text = "Highscore: " + str(hs)
	
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
	if save_manager:
		var difficulty_str = Difficulty.keys()[current_difficulty].to_lower()
		save_manager.update_highscore(difficulty_str, score)
		save_manager.update_stats(platforms)
