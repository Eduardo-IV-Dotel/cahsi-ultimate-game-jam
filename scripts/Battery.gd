extends Area2D

var current_frame: int = 0
const total_frames: int = 10
const fps: float = 12.0
var timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("Sprite2D node: ", $Sprite2D)

func _process(delta: float) -> void:
	timer += delta
	if timer >= 1.0 / fps:
		timer = 0.0
		current_frame = (current_frame + 1) % total_frames
		$Sprite2D.frame = int(current_frame)
		

func _on_body_entered(body: Node) -> void:
	if body.name == "player":
		var player = body as PlayerController
		if player:
			player.max_health += 25.0  # ← increase max health
			player.health += 25.0 # ← fill to new max
			print("Battery picked up! Max health: ", player.max_health)
			queue_free()
