extends Area2D

func _ready() -> void:
	body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body.name == "player":
		var player = body as PlayerController
		if player:
			player.health += 10
			player.charging()
