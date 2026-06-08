extends Node

class_name ShopManager

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

var save_manager: SaveManager
var current_skin = "default"
var player_coins = 0

func _ready():
	add_to_group("shop_manager")
	save_manager = get_tree().get_first_node_in_group("save_manager")
	load_shop_data()

func load_shop_data():
	# Load from save manager if exists
	if save_manager:
		player_coins = save_manager.get_coins()
		current_skin = save_manager.get_current_skin()
		var owned_skins = save_manager.get_owned_skins()
		for skin in owned_skins:
			if skin in knife_skins:
				knife_skins[skin]["owned"] = true

func buy_skin(skin_name: String) -> bool:
	if skin_name not in knife_skins:
		return false
	
	var skin = knife_skins[skin_name]
	
	# Already owned
	if skin["owned"]:
		set_current_skin(skin_name)
		return true
	
	# Not enough coins
	if player_coins < skin["price"]:
		return false
	
	# Purchase
	player_coins -= skin["price"]
	skin["owned"] = true
	set_current_skin(skin_name)
	save_shop_data()
	return true

func set_current_skin(skin_name: String) -> bool:
	if skin_name not in knife_skins or not knife_skins[skin_name]["owned"]:
		return false
	
	current_skin = skin_name
	save_shop_data()
	return true

func add_coins(amount: int):
	player_coins += amount
	save_shop_data()

func get_current_skin_data() -> Dictionary:
	return knife_skins[current_skin]

func get_all_skins() -> Dictionary:
	return knife_skins

func save_shop_data():
	if save_manager:
		save_manager.save_coins(player_coins)
		save_manager.save_current_skin(current_skin)
		var owned_skins = []
		for skin_name in knife_skins:
			if knife_skins[skin_name]["owned"]:
				owned_skins.append(skin_name)
		save_manager.save_owned_skins(owned_skins)
