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
	"red":    $CenterContainer/ButtonGrid/RedButton,
	"green":  $CenterContainer/ButtonGrid/GreenButton,
	"blue":   $CenterContainer/ButtonGrid/BlueButton,
	"yellow": $CenterContainer/ButtonGrid/YellowButton
}
@onready var score_label      : Label   = $HUD/ScoreLabel
@onready var turn_label       : Label   = $HUD/TurnLabel
@onready var high_score_label : Label   = $HUD/HighScoreLabel


# Signal emitted when the player clicks a color button
signal color_selected(color: String)

# ─── Lifecycle ────────────────────────────────────────────────
func _ready() -> void:
	# Set all buttons to their dim (off) color at start
	for color in COLORS:
		buttons[color].color = COLOR_OFF[color]
	_connect_buttons()
	

# ─── Button input ─────────────────────────────────────────────
# Connect each ColorRect's gui_input signal to this function,
# passing the color name as a bind parameter.
# Example connection (in _ready or via editor):
#   buttons["red"].gui_input.connect(_on_button_input.bind("red"))

func _connect_buttons() -> void:
	for color in COLORS:
		if not buttons[color].gui_input.is_connected(_on_button_input):
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
	#high_score_label.text = "Best: %d"  % read_high_score()

# ─── High Score (uses user:// so it persists on device) ───────
#func read_high_score() -> int:
	#if not FileAccess.file_exists(HIGH_SCORE_PATH):
		#return 0
	#var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.READ)
	#var val  := file.get_line().strip_edges().to_int()
	#file.close()
	#return val
#
#func write_high_score(new_score: int) -> void:
	#if new_score > read_high_score():
		#var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.WRITE)
		#file.store_line(str(new_score))
		#file.close()

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
	var choice: String = COLORS[randi() % COLORS.size()]
	if cpu_sequence.size() > 0 and cpu_sequence[-1] == choice:
		choice = COLORS[randi() % COLORS.size()]
	cpu_sequence.append(choice)
	# NO flash here — repeat_sequence handles it
	players_turn = true
	update_hud()

func player_turn() -> bool:
	player_sequence.clear()
	accepting_input = true

	while player_sequence.size() < cpu_sequence.size():
		var chosen: String = await color_selected
		accepting_input = false  # ← disable during flash
		await flash_button(chosen)
		accepting_input = true   # ← re-enable after
		player_sequence.append(chosen)

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



func game_loop(difficulty: int = 4) -> bool:
	cpu_sequence.clear()
	player_sequence.clear()
	score        = 0
	players_turn = false
	update_hud()

	while difficulty > 0:
		cpu_turn()           # ← pick color first
		await repeat_sequence()  # ← then show the whole sequence
		await get_tree().create_timer(0.3).timeout

		var success: bool = await player_turn()

		if not success:
			return false

		score += 1
		update_hud()
		await get_tree().create_timer(1.0).timeout
		difficulty -= 1
	return true
	#write_high_score(score)
	#print("Game Over! Score: %d | Best: %d" % [score, read_high_score()])
	#retry_screen.show()
