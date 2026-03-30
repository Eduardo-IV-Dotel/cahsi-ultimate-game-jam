extends CharacterBody2D
class_name PlayerController

const Dash_Speed = 800.0
const Dash_Duration = 0.2 
const Dash_Cooldown = 1.0
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction = 0
var max_health = 100.0
var health = 100.0
var decay = 5.0
var is_dead := false
var is_charging := false
var is_dashing := false
var can_dash := true
var dash_dir := Vector2.ZERO

func die():
	print("Ya dead")
	is_dead = true
	get_tree().change_scene_to_file("res://scenes/areas/dead_screen.tscn")
func charging():
	is_charging = true


	
func isDecaying():
	decay = 5.0
func stopDecaying():
	decay = 0
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if is_dead:
		velocity = Vector2.ZERO  # stop movement
		move_and_slide()
		return  # ← stop ALL processing when dead, no decay, no die() calls
	
	if is_charging:
		health += 10
	
	health -= decay * delta
	health = clamp(health, 0, max_health)
	if health <= 0:
		die()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if is_dead == false:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("left", "right")
	if direction:
		if is_dead == false:
			velocity.x = direction * SPEED
	

	else:
		if is_dead == false:
			velocity.x = move_toward(velocity.x, 0, SPEED)
				
	#Dash Input Stuff
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()
		
	
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
	
	if is_dashing:
		velocity.x = dash_dir.x * Dash_Speed
		velocity.y = dash_dir.y * (Dash_Speed/2)
	elif direction:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	
		
		
	move_and_slide()
	
	
func start_dash():
	is_dashing = true
	can_dash = false
	var input_dir = Input.get_vector("left", "right", "up", "down")
	if input_dir == Vector2.ZERO:
		input_dir = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT
	dash_dir = input_dir.normalized()
	await get_tree().create_timer(Dash_Duration).timeout
	is_dashing = false
	await get_tree().create_timer(Dash_Duration).timeout
	can_dash = true
