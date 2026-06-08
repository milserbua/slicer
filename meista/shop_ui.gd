extends Control

class_name ShopUI

@onready var shop_button = get_parent().get_node("ShopButton")
var is_shop_open = false
var shop_manager: ShopManager

func _ready():
	shop_button.pressed.connect(_on_shop_button_pressed)
	
	# Get shop manager from game manager
	var game_manager = get_tree().root.get_child(0)
	if game_manager and game_manager.has_meta("shop_manager"):
		shop_manager = game_manager.get_meta("shop_manager")
	else:
		# Try to find it in groups
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
	style.set_border_enabled(true)
	style.set_border_width_all(2)
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
	
	# Skins list (placeholder - will be populated)
	for i in range(6):
		var skin_button = Button.new()
		skin_button.text = "Skin %d" % i
		skin_button.custom_minimum_size = Vector2(0, 50)
		skin_button.pressed.connect(func(): _on_skin_selected(i))
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
	
	var coins_label = get_node("ShopPanel/VBoxContainer/CoinsDisplayLabel")
	if coins_label:
		coins_label.text = "💰 Coins: %d" % shop_manager.player_coins

func _on_skin_selected(skin_index: int):
	print("Skin %d selected" % skin_index)
	if shop_manager:
		# TODO: Implement skin purchase logic
		pass

func _on_close_shop():
	is_shop_open = false
	visible = false
	get_tree().paused = false
