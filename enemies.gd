extends CharacterBody2D

@export var speed: float = 100.0
@export var patrol_distance: float = 200.0  # how far it walks each way

var direction: float = 1.0  # 1 = right, -1 = left
var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Move left and right
	velocity.x = direction * speed
	
	# Flip direction when too far from start
	if global_position.x > start_position.x + patrol_distance:
		direction = -1.0
	elif global_position.x < start_position.x - patrol_distance:
		direction = 1.0
	
	move_and_slide()
