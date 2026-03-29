extends Node2D
@export var player_control : PlayerController
@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D


func _process(delta: float):
	var HealthPercentage= player_control.health / player_control.max_health * 100
	print("health: ", player_control.health, " max: ", player_control.max_health, " pct: ", HealthPercentage)
	if player_control.direction == 1:
		sprite.flip_h = true
	elif player_control.direction == -1:
		sprite.flip_h = false
		
	if abs(player_control.velocity.x) > 0.0:
		if HealthPercentage >=75: 
			animation_player.play("move_green")
		elif (HealthPercentage < 75) && (HealthPercentage >= 35):
			animation_player.play("move_yellow")
		elif HealthPercentage < 35:
			animation_player.play("move_red")

	else:
		if HealthPercentage >=75: 
			animation_player.play("idle_green")
		elif (HealthPercentage < 75) && (HealthPercentage >= 35):
			animation_player.play("idle_yellow")
		elif HealthPercentage < 35:
			animation_player.play("idle_red")
			
	if player_control.is_dead == true:
		animation_player.play("dead")
