extends Area2D

@export var simon_says_scene: PackedScene

var triggered := false
var unlocked := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "player" and not triggered:
		var player = body as PlayerController
		if not unlocked:
			triggered = true
			player.is_dead = false
			player.health = player.max_health
			player.stopDecaying()
			player.set_physics_process(false)  # freeze player
			var simon = simon_says_scene.instantiate()
			get_tree().root.add_child(simon)
			var won: bool = await simon.get_child(0).game_loop(4)
			simon.queue_free()
			player.set_physics_process(true)   # unfreeze player
			player.isDecaying()
			if won:
				unlocked = true
				triggered = false
				player.is_dead = false
				player.health = player.max_health
				player.charging()
				print("Recharged!")
			else:
				triggered = false
		else:
			player.charging()

func _on_body_exited(body: Node) -> void:
	if body.name == "player":
		var player = body as PlayerController
		if player:
			player.is_charging = false
