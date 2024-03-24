extends CharacterBody2D


@export var SPEED: float = 700.0
@export var playerNode2D: Node2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var throw_power: float = 1.0

func _ready():
	direction = Vector2(1,0).rotated(rotation)
	velocity = SPEED * direction * throw_power

func destroy():
	queue_free()

func _physics_process(delta):
	velocity.y += gravity * 1 * delta
	
	if velocity.x >= 0:
		rotation = asin(velocity.y / sqrt(velocity.y ** 2 + velocity.x ** 2))
	else:
		rotation = 135 - asin(velocity.y / sqrt(velocity.y ** 2 + velocity.x ** 2))
		
	if is_on_floor():
		destroy()
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body != playerNode2D:
		print("Player hit")
	destroy()
	pass # Replace with function body.

func _on_area_2d_area_entered(area):
	destroy()
	pass # Replace with function body.
