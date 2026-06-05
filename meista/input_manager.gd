extends Control

@export var input_type = "keyboard"  # keyboard, touch, gamepad

var is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"

func _ready():
	if is_mobile:
		setup_touch_controls()
	else:
		setup_keyboard_controls()

func setup_keyboard_controls():
	# Standard keyboard input is handled by Godot's default input map
	pass

func setup_touch_controls():
	# Create touch button area
	var touch_button = TouchScreenButton.new()
	touch_button.shape = CircleShape2D.new()
	touch_button.bounding_rect = Rect2(0, 0, 200, 200)
	touch_button.position = Vector2(get_viewport().get_visible_rect().size.x / 2, 
									get_viewport().get_visible_rect().size.y - 100)
	touch_button.action = "ui_accept"
	add_child(touch_button)

func _process(delta):
	if is_mobile:
		handle_mobile_input(delta)
	else:
		handle_gamepad_input(delta)

func handle_mobile_input(delta):
	# Swipe detection for alternative controls
	if Input.is_action_pressed("ui_touch"):
		var touch_pos = get_local_mouse_position()
		# Could add swipe logic here

func handle_gamepad_input(delta):
	# Gamepad support for jumping
	if Input.is_action_just_pressed("gamepad_jump"):
		Input.action_press("ui_accept")
		await get_tree().create_timer(0.1).timeout
		Input.action_release("ui_accept")

func get_supported_inputs() -> Array:
	var inputs = ["keyboard"]
	if Input.get_connected_joypads().size() > 0:
		inputs.append("gamepad")
	if is_mobile:
		inputs.append("touch")
	return inputs
