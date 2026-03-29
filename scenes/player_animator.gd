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
		if player_control.health >=75: 
			animation_player.play("move_green")
		elif (player_control.health < 75) && (player_control.health >= 35):
			animation_player.play("move_yellow")
		elif player_control.health < 35:
			animation_player.play("move_red")

	else:
		if player_control.health >=75: 
			animation_player.play("idle_green")
		elif (player_control.health < 75) && (player_control.health >= 35):
			animation_player.play("idle_yellow")
		elif player_control.health < 35:
			animation_player.play("idle_red")
			
	if player_control.is_dead == true:
		animation_player.play("dead")
