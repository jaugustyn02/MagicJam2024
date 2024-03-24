extends CharacterBody2D

@export var projectile :PackedScene


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_THROW_DURATION = 0.5

var PlayerID: int
var throw_press_duration = 0.0

const fibonacci_golden_throw_cooldown = 0.5
var throw_cooldown = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@rpc("any_peer", "call_local")
func add_projectile(throw_power: float):
	var p = projectile.instantiate()
	p.global_position = $CursorPointer/ProjectileSpawn.global_position
	p.rotation_degrees = $CursorPointer.rotation_degrees
	p.playerNode2D = self
	p.throw_power = throw_power
	get_tree().root.add_child(p)


func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	PlayerID = multiplayer.get_unique_id()

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == PlayerID:
		if not is_on_floor():
			velocity.y += gravity * delta
			
		$CursorPointer.look_at(get_viewport().get_mouse_position())

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("range_attack"):
			throw_press_duration = 0.0
		
		if throw_cooldown <= 0.0 and Input.is_action_just_released("range_attack"):
			var throw_power = min(MAX_THROW_DURATION, throw_press_duration) + 1.0
			add_projectile.rpc(throw_power)
			throw_cooldown = fibonacci_golden_throw_cooldown
			#print("Range attack pressed for:", throw_press_duration, "seconds")
			

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		throw_press_duration += delta
		throw_cooldown -= delta
		move_and_slide()
