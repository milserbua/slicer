extends Control

var selected_difficulty = 1
var game_manager: Node3D

func _ready():
	create_menu_ui()
	show()

func create_menu_ui():
	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -150
	vbox.offset_top = -200
	vbox.offset_right = 150
	vbox.offset_bottom = 200
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "SLICER MASTER"
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer1)
	
	var difficulty_label = Label.new()
	difficulty_label.text = "SELECT DIFFICULTY"
	difficulty_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(difficulty_label)
	
	var difficulties = ["EASY", "NORMAL", "HARD"]
	for i in range(difficulties.size()):
		var btn = Button.new()
		btn.text = difficulties[i]
		btn.custom_minimum_size = Vector2(200, 50)
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(_on_difficulty_selected.bindv([i]))
		vbox.add_child(btn)
	
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer2)
	
	var start_btn = Button.new()
	start_btn.text = "START GAME"
	start_btn.custom_minimum_size = Vector2(200, 60)
	start_btn.add_theme_font_size_override("font_size", 28)
	start_btn.pressed.connect(_on_start_game)
	vbox.add_child(start_btn)

func _on_difficulty_selected(difficulty: int):
	selected_difficulty = difficulty
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.set_difficulty(difficulty)

func _on_start_game():
	hide()
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.game_state = "playing"

func show_pause_menu():
	show()

func hide_pause_menu():
	hide()
