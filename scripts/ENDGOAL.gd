extends Area2D

@export var main_menu_scene: PackedScene

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	print("end station triggered by: ", body.name)
	if body.name == "player":
		show_congratulations()

func show_congratulations() -> void:
	# Pause the game
	get_tree().paused = true
	
	# Create a simple congratulations overlay
	var canvas = CanvasLayer.new()
	var panel = ColorRect.new()
	var label = Label.new()
	var button = Button.new()
	
	# Setup panel (dark overlay)
	panel.color = Color(0, 0, 0, 0.8)
	panel.anchors_preset = Control.PRESET_FULL_RECT
	
	# Setup label
	label.text = "YOU WIN!\nCongratulations!\nYou escaped!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_CENTER
	label.position = Vector2(-200, -100)
	label.size = Vector2(400, 150)
	label.add_theme_font_size_override("font_size", 32)
	
	# Setup button
	button.text = "Back to Main Menu"
	button.anchors_preset = Control.PRESET_CENTER
	button.position = Vector2(-100, 50)
	button.size = Vector2(200, 50)
	button.pressed.connect(_on_menu_pressed)
	
	# Add everything
	canvas.add_child(panel)
	canvas.add_child(label)
	canvas.add_child(button)
	get_tree().root.add_child(canvas)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)
