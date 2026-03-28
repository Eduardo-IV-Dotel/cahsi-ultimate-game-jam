extends Area2D

func _ready() -> void:
	body_entered.connect(_on_area_2d_body_entered)
	body_exited.connect(_on_body_exited)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var player = body as PlayerController
		if player:
			player.charging()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		var player = body as PlayerController
		if player:
			player.is_charging = false
