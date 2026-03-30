extends Area2D

@export var simon_says_scene: PackedScene

var triggered := false
var unlocked := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)  # ← add this

func _on_body_exited(body: Node) -> void:
	if body.name == "player":
		var player = body as PlayerController
		if player:
			player.is_charging = false

func _on_body_entered(body: Node) -> void:
	if body.name == "player" and not triggered:
		var player = body as PlayerController
		if not unlocked:
			triggered = true
			player.decay = 0.0
			player.is_dead = false
			player.set_physics_process(false)  # ← freeze player completely
			var simon = simon_says_scene.instantiate()
			get_tree().root.add_child(simon)
			var won: bool = await simon.get_child(0).game_loop(4)
			simon.queue_free()
			player.set_physics_process(true)   # ← unfreeze after
			player.isDecaying()
			if won:
				unlocked = true
				triggered = false
				player.health = player.max_health
				player.is_dead = false
				player.is_charging = true
				player.decay = 5.0
				print("Recharged!")
			else:
				player.decay = 5.0
				triggered = false
		else:
			player.health = player.max_health
			player.is_dead = false
			player.is_charging = true

func recharge(body: Node) -> void:
	print("recharge called on: ", body.name)
	print("body class: ", body.get_class())
	var player = body as PlayerController
	print("player cast result: ", player)
	if player:
		player.health = player.max_health
		player.is_dead = false
		player.is_charging = true
		print("is_dead is now: ", player.is_dead)
	else:
		print("CAST FAILED")
