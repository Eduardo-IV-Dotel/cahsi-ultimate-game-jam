extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var battery := 100.0
var max_battery := 100.0
var drain_rate := 10.0   
var recharge_rate := 5.0 


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	batery -= drain_rate * delta
	battery = clamp(battery, 0, max_battery)
	move_and_slide()
