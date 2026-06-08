extends Control

class_name ShopUI

var is_shop_open = false
var shop_manager: Node
var shop_button: Button

func _ready():
	# Warte bis Shop Button verfügbar ist
	await get_tree().process_frame
	
	shop_button = get_parent().get_node("ShopButton")
	if shop_button:
		shop_button.pressed.connect(_on_shop_button_pressed)
	
	# Get shop manager from groups
	var managers = get_tree().get_nodes_in_group("shop_manager")
	if managers.size() > 0:
		shop_manager = managers[0]
	
	# Create shop UI
	_create_shop_ui()

func _create_shop_ui():
	var panel = PanelContainer.new()
	panel.name = "ShopPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300
	panel.offset_top = -250
	panel.offset_right = 300
	panel.offset_bottom = 250
	add_child(panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_color = Color(1, 1, 1, 0.5)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🛍️ SHOP"
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	# Separator
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	# Coins display
	var coins_label = Label.new()
	coins_label.text = "Coins: 0"
	coins_label.name = "CoinsDisplayLabel"
	coins_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(coins_label)
	
	# Scroll for skins
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 300)
	vbox.add_child(scroll)
	
	var skin_vbox = VBoxContainer.new()
	skin_vbox.name = "SkinsContainer"
	scroll.add_child(skin_vbox)
	
	# Skins list
	var skins = [
		{"name": "Classic", "price": 0, "color": Color(0.7, 0.7, 0.7)},
		{"name": "Gold Rush", "price": 500, "color": Color(1, 0.84, 0)},
		{"name": "Crimson", "price": 750, "color": Color(0.85, 0.1, 0.1)},
		{"name": "Icy", "price": 600, "color": Color(0.3, 0.8, 1)},
		{"name": "Shadow", "price": 800, "color": Color(0.2, 0.2, 0.2)},
		{"name": "Rainbow", "price": 1200, "color": Color(1, 0.2, 0.8)}
	]
	
	for i in range(skins.size()):
		var skin_button = Button.new()
		skin_button.text = "%s - %d💰" % [skins[i]["name"], skins[i]["price"]]
		skin_button.custom_minimum_size = Vector2(0, 50)
		# Fix: Capture index properly to avoid closure issues
		var skin_index = i
		skin_button.pressed.connect(func(): _on_skin_selected(skin_index))
		skin_vbox.add_child(skin_button)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.pressed.connect(_on_close_shop)
	vbox.add_child(close_button)

func _on_shop_button_pressed():
	is_shop_open = !is_shop_open
	visible = is_shop_open
	
	if is_shop_open:
		get_tree().paused = true
		_update_shop_display()
	else:
		get_tree().paused = false

func _update_shop_display():
	if not shop_manager:
		return
	
	var coins_label = get_node_or_null("ShopPanel/VBoxContainer/CoinsDisplayLabel")
	if coins_label:
		coins_label.text = "💰 Coins: %d" % shop_manager.player_coins

func _on_skin_selected(skin_index: int):
	print("Skin %d selected" % skin_index)
	if shop_manager:
		shop_manager.set_current_skin(["default", "gold", "crimson", "ice", "shadow", "rainbow"][skin_index])

func _on_close_shop():
	is_shop_open = false
	visible = false
	get_tree().paused = false
