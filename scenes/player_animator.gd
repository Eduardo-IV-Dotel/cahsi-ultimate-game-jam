extends Node2D
@export var player_control : PlayerController
@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D

func _process(delta: float):
	if player_control.direction == 1:
		sprite.flip_h = true
	elif player_control.direction == -1:
		sprite.flip_h = false
		
	if abs(player_control.velocity.x) > 0.0:
		animation_player.play("leftgreen")
	else: 
		animation_player.play("idlegreen")
