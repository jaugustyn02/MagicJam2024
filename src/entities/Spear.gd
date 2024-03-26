extends CharacterBody2D


@export var SPEED: float = 700.0
@export var playerNode2D: Node2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var throw_power: float = 1.0
var time_multiplier: float = 1.0
var base_x_velocity: float
var previous_velocity: Vector2

func _ready():
	direction = Vector2(1,0).rotated(rotation)
	velocity = SPEED * direction * throw_power * time_multiplier

func destroy():
	queue_free()

func _physics_process(delta):
	if previous_velocity and velocity.x == 0 and abs(previous_velocity.x - velocity.x) > 0.05:
		velocity.x = previous_velocity.x * -0.33
	velocity.y += gravity * 1 * delta * (time_multiplier ** 2)
	
	if velocity.x >= 0:
		rotation = asin(velocity.y / sqrt(velocity.y ** 2 + velocity.x ** 2))
	else:
		rotation = 135 - asin(velocity.y / sqrt(velocity.y ** 2 + velocity.x ** 2))
		
	if is_on_floor():
		destroy()
	previous_velocity = velocity
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body != playerNode2D:
		destroy()
