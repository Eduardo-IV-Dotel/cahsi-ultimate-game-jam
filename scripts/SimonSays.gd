extends Control

# ─── Constants ────────────────────────────────────────────────
const COLORS := ["red", "green", "blue", "yellow"]

const COLOR_ON := {
	"red":    Color(1.0, 0.0, 0.0),
	"green":  Color(0.0, 1.0, 0.0),
	"blue":   Color(0.0, 0.0, 1.0),
	"yellow": Color(1.0, 1.0, 0.0)
}
const COLOR_OFF := {
	"red":    Color(0.55, 0.0, 0.0),
	"green":  Color(0.0, 0.55, 0.0),
	"blue":   Color(0.0, 0.0, 0.55),
	"yellow": Color(0.55, 0.55, 0.0)
}

const HIGH_SCORE_PATH := "user://score.txt"
const FLASH_ON_DURATION  := 0.4  # seconds button stays lit
const FLASH_OFF_DURATION := 0.25 # gap between flashes

# ─── State ────────────────────────────────────────────────────
var cpu_sequence:    Array[String] = []
var player_sequence: Array[String] = []
var score:           int  = 0
var players_turn:    bool = false
var accepting_input: bool = false

# ─── Node refs ────────────────────────────────────────────────
@onready var buttons := {
	"red":    $ButtonGrid/RedButton,
	"green":  $ButtonGrid/GreenButton,
	"blue":   $ButtonGrid/BlueButton,
	"yellow": $ButtonGrid/YellowButton
}
@onready var score_label      : Label   = $HUD/ScoreLabel
@onready var turn_label       : Label   = $HUD/TurnLabel
@onready var high_score_label : Label   = $HUD/HighScoreLabel
@onready var retry_screen     : Control = $RetryScreen

# Signal emitted when the player clicks a color button
signal color_selected(color: String)

# ─── Lifecycle ────────────────────────────────────────────────
func _ready() -> void:
	# Set all buttons to their dim (off) color at start
	for color in COLORS:
		buttons[color].color = COLOR_OFF[color]
	retry_screen.hide()
	game_loop()

# ─── Button input ─────────────────────────────────────────────
# Connect each ColorRect's gui_input signal to this function,
# passing the color name as a bind parameter.
# Example connection (in _ready or via editor):
#   buttons["red"].gui_input.connect(_on_button_input.bind("red"))

func _connect_buttons() -> void:
	for color in COLORS:
		buttons[color].gui_input.connect(_on_button_input.bind(color))

func _on_button_input(event: InputEvent, color: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if accepting_input:
				emit_signal("color_selected", color)

# ─── HUD ──────────────────────────────────────────────────────
func update_hud() -> void:
	score_label.text      = "Score: %d" % score
	turn_label.text       = "Your Turn" if players_turn else "CPU's Turn"
	high_score_label.text = "Best: %d"  % read_high_score()

# ─── High Score (uses user:// so it persists on device) ───────
func read_high_score() -> int:
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		return 0
	var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.READ)
	var val  := file.get_line().strip_edges().to_int()
	file.close()
	return val

func write_high_score(new_score: int) -> void:
	if new_score > read_high_score():
		var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.WRITE)
		file.store_line(str(new_score))
		file.close()

# ─── Button flash ─────────────────────────────────────────────
func flash_button(color: String) -> void:
	var btn    : ColorRect          = buttons[color]
	var sound  : AudioStreamPlayer  = btn.get_node("Sound")

	btn.color = COLOR_ON[color]
	if sound.stream != null and sound != null:
		sound.play()
	await get_tree().create_timer(FLASH_ON_DURATION).timeout

	btn.color = COLOR_OFF[color]
	await get_tree().create_timer(FLASH_OFF_DURATION).timeout

# ─── Game phases ──────────────────────────────────────────────
func repeat_sequence() -> void:
	players_turn = false
	update_hud()
	for color in cpu_sequence:
		await flash_button(color)

func cpu_turn() -> void:
	# Pick a random color; retry once if it's the same as the last
	var choice: String = COLORS[randi() % COLORS.size()]
	if cpu_sequence.size() > 0:
		choice = COLORS[randi() % COLORS.size()]

	cpu_sequence.append(choice)
	await flash_button(choice)

	players_turn = true
	update_hud()

func player_turn() -> bool:
	player_sequence.clear()
	accepting_input = true

	while player_sequence.size() < cpu_sequence.size():
		# Wait here until the player emits color_selected
		var chosen: String = await color_selected
		await flash_button(chosen)
		player_sequence.append(chosen)

		# Check what the player has typed so far
		if not _sequence_valid():
			accepting_input = false
			return false

	accepting_input = false
	return true

func _sequence_valid() -> bool:
	for i in range(player_sequence.size()):
		if player_sequence[i] != cpu_sequence[i]:
			return false
	return true

# ─── Game flow ────────────────────────────────────────────────
func game_loop() -> void:
	cpu_sequence.clear()
	player_sequence.clear()
	score        = 0
	players_turn = false
	_connect_buttons()
	update_hud()
	var difficulty = 4
	

	while true:
		await repeat_sequence()
		await get_tree().create_timer(0.3).timeout
		await cpu_turn()

		var success: bool = await player_turn()

		if not success:
			game_over()
			return  # stops the loop; retry restarts game_loop()

		score += 1
		update_hud()
		await get_tree().create_timer(1.0).timeout
		difficulty -= 1


func game_over() -> void:
	write_high_score(score)
	print("Game Over! Score: %d | Best: %d" % [score, read_high_score()])
	retry_screen.show()

# Called by the RetryButton's pressed signal
func _on_retry_pressed() -> void:
	retry_screen.hide()
	game_loop()
