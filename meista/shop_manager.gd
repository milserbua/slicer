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

var current_skin = "default"
var player_coins = 0
var skin_changed = Signal()

func _ready():
	add_to_group("shop_manager")

func buy_skin(skin_id: String) -> bool:
	if skin_id not in knife_skins:
		print("❌ Skin not found: %s" % skin_id)
		return false
	
	var skin = knife_skins[skin_id]
	
	# Already owned - just switch to it
	if skin["owned"]:
		return set_current_skin(skin_id)
	
	# Not enough coins
	if player_coins < skin["price"]:
		print("❌ Not enough coins: need %d, have %d" % [skin["price"], player_coins])
		return false
	
	# Purchase
	player_coins -= skin["price"]
	skin["owned"] = true
	print("✅ Purchased %s for %d coins! Coins left: %d" % [skin["name"], skin["price"], player_coins])
	set_current_skin(skin_id)
	return true

func set_current_skin(skin_id: String) -> bool:
	if skin_id not in knife_skins or not knife_skins[skin_id]["owned"]:
		print("❌ Cannot set skin - not owned: %s" % skin_id)
		return false
	
	current_skin = skin_id
	print("✅ Knife skin changed to: %s" % knife_skins[skin_id]["name"])
	skin_changed.emit()
	return true

func add_coins(amount: int):
	player_coins += amount
	print("💰 Coins added: %d (Total: %d)" % [amount, player_coins])

func get_current_skin_data() -> Dictionary:
	return knife_skins[current_skin]

func get_all_skins() -> Dictionary:
	return knife_skins

func get_skin_by_id(skin_id: String) -> Dictionary:
	return knife_skins.get(skin_id, {})

func is_skin_owned(skin_id: String) -> bool:
	return knife_skins.get(skin_id, {}).get("owned", false)
