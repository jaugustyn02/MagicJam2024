extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

var playerID: int
var time_multiplier: float = 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	playerID = multiplayer.get_unique_id()

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != playerID:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * (time_multiplier ** 2) * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY * time_multiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED * time_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func on_time_multiplier_changed(new_time_multiplier):
	time_multiplier = new_time_multiplier
