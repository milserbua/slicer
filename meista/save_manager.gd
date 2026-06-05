extends Node

class_name SaveManager

const SAVE_FILE = "user://slicer_save.json"

var highscores = {
	"easy": 0,
	"normal": 0,
	"hard": 0,
	"global": 0
}

var player_stats = {
	"total_platforms": 0,
	"total_games": 0,
	"favorite_difficulty": "normal"
}

func _ready():
	load_game_data()

func save_game_data():
	var data = {
		"highscores": highscores,
		"stats": player_stats
	}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(data)

func load_game_data():
	if ResourceLoader.exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var data = file.get_var()
			if data:
				highscores = data.get("highscores", highscores)
				player_stats = data.get("stats", player_stats)

func update_highscore(difficulty: String, score: int):
	if difficulty in highscores:
		if score > highscores[difficulty]:
			highscores[difficulty] = score
	
	if score > highscores["global"]:
		highscores["global"] = score
	
	save_game_data()

func get_highscore(difficulty: String) -> int:
	return highscores.get(difficulty, 0)

func update_stats(platforms: int):
	player_stats["total_platforms"] += platforms
	player_stats["total_games"] += 1
	save_game_data()
