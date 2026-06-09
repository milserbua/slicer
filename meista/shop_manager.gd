extends Node

class_name ShopManager

signal skin_changed
signal coins_changed(new_amount)

var knife_skins = {
	"default": {
		"name": "Classic",
		"description": "The original knife",
		"color": Color(0.45119858, 0.5112577, 0.48495245, 1),
		"price": 0,
		"owned": true
	},
	"gold": {
		"name": "Gold Rush",
		"description": "Shiny golden blade",
		"color": Color(1.0, 0.84, 0.0, 1),
		"price": 500,
		"owned": false
	},
	"crimson": {
		"name": "Crimson",
		"description": "Blood red blade",
		"color": Color(0.8, 0.1, 0.1, 1),
		"price": 750,
		"owned": false
	},
	"ice": {
		"name": "Icy",
		"description": "Frozen blue blade",
		"color": Color(0.3, 0.8, 1.0, 1),
		"price": 600,
		"owned": false
	},
	"shadow": {
		"name": "Shadow",
		"description": "Dark mysterious blade",
		"color": Color(0.2, 0.2, 0.2, 1),
		"price": 800,
		"owned": false
	},
	"rainbow": {
		"name": "Rainbow",
		"description": "Magical colorful blade",
		"color": Color(1.0, 0.5, 0.5, 1),
		"price": 1200,
		"owned": false
	}
}

var current_skin = "default"
var player_coins = 0

var save_file = "user://slicer_save.json"

func _ready():
	add_to_group("shop_manager")
	print("🔧 ShopManager initializing...")
	load_player_data()
	print("✅ ShopManager ready. Coins: %d" % player_coins)

func load_player_data():
	print("📂 Attempting to load from: %s" % save_file)

	if FileAccess.file_exists(save_file):
		print("📄 Save file found!")
		var file = FileAccess.open(save_file, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			print("📋 File content: %s" % json_string)
			var data = JSON.parse_string(json_string)

			if data:
				player_coins = data.get("coins", 0)
				current_skin = data.get("current_skin", "default")

				if data.has("owned_skins"):
					for skin_id in data["owned_skins"]:
						if skin_id in knife_skins:
							knife_skins[skin_id]["owned"] = true

				if current_skin not in knife_skins:
					current_skin = "default"

				if not knife_skins["default"]["owned"]:
					knife_skins["default"]["owned"] = true

				print("✅ Loaded! Coins: %d, Skin: %s" % [player_coins, current_skin])
			else:
				print("⚠️ JSON parse failed, starting fresh")
				save_player_data()
		else:
			print("❌ Could not read file")
	else:
		print("📄 No save file found, creating new one")
		save_player_data()

func save_player_data():
	print("💾 Saving player data...")
	var owned_skins = []
	for skin_id in knife_skins:
		if knife_skins[skin_id]["owned"]:
			owned_skins.append(skin_id)

	var data = {
		"coins": player_coins,
		"current_skin": current_skin,
		"owned_skins": owned_skins
	}

	var json_string = JSON.stringify(data)
	print("📝 Data to save: %s" % json_string)

	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("✅ Saved successfully! Coins: %d" % player_coins)
	else:
		print("❌ Failed to open file for writing")

func buy_skin(skin_id: String) -> bool:
	if skin_id not in knife_skins:
		print("❌ Skin not found: %s" % skin_id)
		return false

	var skin = knife_skins[skin_id]

	if skin["owned"]:
		return set_current_skin(skin_id)

	if player_coins < skin["price"]:
		print("❌ Not enough coins: need %d, have %d" % [skin["price"], player_coins])
		return false

	player_coins -= skin["price"]
	skin["owned"] = true

	print("✅ Purchased %s for %d coins! Coins left: %d" % [skin["name"], skin["price"], player_coins])
	save_player_data()
	coins_changed.emit(player_coins)
	return set_current_skin(skin_id)

func set_current_skin(skin_id: String) -> bool:
	if skin_id not in knife_skins or not knife_skins[skin_id]["owned"]:
		print("❌ Cannot set skin - not owned: %s" % skin_id)
		return false

	current_skin = skin_id
	print("✅ Knife skin changed to: %s" % knife_skins[skin_id]["name"])
	save_player_data()
	skin_changed.emit()
	return true

func add_coins(amount: int):
	if amount <= 0:
		return

	player_coins += amount
	print("💰 Coins added: +%d (Total: %d)" % [amount, player_coins])
	save_player_data()
	coins_changed.emit(player_coins)

func get_current_skin_data() -> Dictionary:
	return knife_skins[current_skin]

func get_all_skins() -> Dictionary:
	return knife_skins

func get_skin_by_id(skin_id: String) -> Dictionary:
	return knife_skins.get(skin_id, {})

func is_skin_owned(skin_id: String) -> bool:
	return knife_skins.get(skin_id, {}).get("owned", false)
