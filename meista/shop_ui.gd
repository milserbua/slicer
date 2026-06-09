extends Control

class_name ShopUI
var coins_display_label: Label
var skin_buttons = {}
var is_shop_open = false
var shop_manager: Node
var shop_button: Button
var selected_skin_index = 0
var coins = 100

func _ready():
	await get_tree().process_frame
	shop_button = get_parent().get_node("ShopButton")
	if shop_button:
		shop_button.pressed.connect(_on_shop_button_pressed)

	var managers = get_tree().get_nodes_in_group("shop_manager")
	if managers.size() > 0:
		shop_manager = managers[0]

	_create_shop_ui()

	if shop_manager:
		if shop_manager.has_signal("coins_changed"):
			shop_manager.coins_changed.connect(_update_shop_display)
		if shop_manager.has_signal("skin_changed"):
			shop_manager.skin_changed.connect(_update_shop_display)

	_update_shop_display()
	_update_shop_display()
	refresh_skin_buttons()	
func _create_shop_ui():
	var panel = PanelContainer.new()
	panel.name = "ShopPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = 30
	panel.offset_top = 20
	panel.offset_right = 300
	panel.offset_bottom = 280
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.15, 0.98)
	style.border_color = Color(0.2, 0.8, 1.0, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "⚔️ KNIFE SHOP ⚔️"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	vbox.add_child(title)

	var separator = HSeparator.new()
	vbox.add_child(separator)

	var coins_container = HBoxContainer.new()
	coins_container.add_theme_constant_override("separation", 8)
	coins_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var coins_icon = Label.new()
	coins_icon.text = "💰"
	coins_icon.add_theme_font_size_override("font_size", 20)
	coins_container.add_child(coins_icon)

	
	coins_display_label = Label.new()
	coins_display_label.text = "Coins: 0"
	coins_display_label.name = "CoinsDisplayLabel"
	
	coins_display_label.add_theme_font_size_override("font_size", 18)
	coins_display_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	coins_container.add_child(coins_display_label)
	vbox.add_child(coins_container)

	vbox.add_child(HSeparator.new())

	var skin_label = Label.new()
	skin_label.text = "Select Knife Skin:"
	skin_label.add_theme_font_size_override("font_size", 14)
	skin_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(skin_label)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 240)
	vbox.add_child(scroll)

	var skin_vbox = VBoxContainer.new()
	skin_vbox.name = "SkinsContainer"
	skin_vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(skin_vbox)

	var skins = [
		{"id": "default", "name": "Classic", "price": 0, "color": Color(0.7, 0.7, 0.7), "emoji": "🔷"},
		{"id": "gold", "name": "Gold Rush", "price": 500, "color": Color(1, 0.84, 0), "emoji": "💛"},
		{"id": "crimson", "name": "Crimson", "price": 750, "color": Color(0.85, 0.1, 0.1), "emoji": "🔴"},
		{"id": "ice", "name": "Icy", "price": 600, "color": Color(0.3, 0.8, 1), "emoji": "🔵"},
		{"id": "shadow", "name": "Shadow", "price": 800, "color": Color(0.2, 0.2, 0.2), "emoji": "⬛"},
		{"id": "rainbow", "name": "Rainbow", "price": 1200, "color": Color(1, 0.5, 0.5), "emoji": "🌈"}
	]

	for i in range(skins.size()):
		var skin_item = HBoxContainer.new()
		skin_item.add_theme_constant_override("separation", 8)
		skin_item.custom_minimum_size = Vector2(0, 45)

		var color_box = ColorRect.new()
		color_box.color = skins[i]["color"]
		color_box.custom_minimum_size = Vector2(40, 40)
		skin_item.add_child(color_box)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var skin_name = Label.new()
		skin_name.text = skins[i]["emoji"] + " " + skins[i]["name"]
		skin_name.add_theme_font_size_override("font_size", 14)
		skin_name.add_theme_color_override("font_color", Color(1, 1, 1))
		info_vbox.add_child(skin_name)

		var price_label = Label.new()
		if skins[i]["price"] == 0:
			price_label.text = "FREE (Unlocked)"
			price_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
		else:
			price_label.text = "💰 " + str(skins[i]["price"])
			price_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		price_label.add_theme_font_size_override("font_size", 12)
		info_vbox.add_child(price_label)

		skin_item.add_child(info_vbox)
		var skin_button = Button.new()
		if shop_manager and shop_manager.is_skin_owned(skins[i]["id"]):
			skin_button.text = "SELECT"
		else:
			skin_button.text = "BUY"
		skin_buttons[skins[i]["id"]] = skin_button
		skin_button.custom_minimum_size = Vector2(85, 40)
		skin_button.add_theme_font_size_override("font_size", 12)

		var skin_index = i
		skin_button.pressed.connect(func(): _on_skin_selected(skin_index, skins[skin_index]))
		skin_item.add_child(skin_button)

		skin_vbox.add_child(skin_item)

	vbox.add_child(HSeparator.new())

	var close_button = Button.new()
	close_button.text = "Close Shop (ESC)"
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.add_theme_font_size_override("font_size", 14)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.8, 0.2, 0.2)
	close_style.border_color = Color(1, 1, 1, 0.5)
	close_style.border_width_left = 2
	close_style.border_width_top = 2
	close_style.border_width_right = 2
	close_style.border_width_bottom = 2
	close_button.add_theme_stylebox_override("normal", close_style)
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

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and is_shop_open:
			_on_close_shop()
			get_tree().root.set_input_as_handled()


func _update_shop_display():
	if not shop_manager:
		return

	if coins_display_label:
		coins_display_label.text = "Coins: %d" % shop_manager.player_coins

	refresh_skin_buttons()

func _on_skin_selected(skin_index: int, skin_data: Dictionary):
	print("Trying to select: %s" % skin_data["name"])
	if shop_manager:
		var skin_id = skin_data["id"]
		var result = shop_manager.buy_skin(skin_id)

		if result:
			print("✅ Skin changed to: %s" % skin_data["name"])
			_update_shop_display()
			refresh_skin_buttons()
		else:
			var current_coins = shop_manager.player_coins
			var price = skin_data["price"]
			if current_coins < price:
				print("❌ Not enough coins! Need %d, have %d" % [price - current_coins, current_coins])
			else:
				print("❌ Failed to select skin")

func _on_close_shop():
	is_shop_open = false
	visible = false
	get_tree().paused = false
	
func refresh_skin_buttons():
	if not shop_manager:
		return

	for skin_id in skin_buttons:
		var button = skin_buttons[skin_id]

		if skin_id == shop_manager.current_skin:
			button.text = "EQUIPPED"
			button.disabled = true
		elif shop_manager.is_skin_owned(skin_id):
			button.text = "SELECT"
			button.disabled = false
		else:
			button.text = "BUY"
			button.disabled = false
