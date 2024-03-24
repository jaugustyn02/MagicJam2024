extends CharacterBody2D

@export var projectile :PackedScene

const SPEED = 400.0
const JUMP_VELOCITY = -800
const INITIAL_LIFETIME = 180.0

const MAX_THROW_DURATION = 0.5
const THROW_COOLDOWN = 0.5

var PlayerID: int
var throw_press_duration = 0.0
var throw_cooldown = 0.0

@export var lifetime: float = INITIAL_LIFETIME
var time_multiplier: float = 1.0
@onready var active_attack_hitbox = $AttackHitboxRight
var attack: float = 0

@onready var anim = get_node("AnimationPlayer")

@export var gravity_counter1: float = -1
@export var gravity_counter2: float = -1
 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@rpc("any_peer", "call_local")
func add_projectile(throw_power: float):
	var p = projectile.instantiate()
	p.global_position = $CursorPointer/ProjectileSpawn.global_position
	p.rotation_degrees = $CursorPointer.rotation_degrees
	p.playerNode2D = self
	p.throw_power = throw_power
	p.time_multiplier = time_multiplier
	get_tree().root.add_child(p)

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	PlayerID = multiplayer.get_unique_id()
	$PlayerHitbox.monitoring = true
	$AttackHitboxLeft.monitoring = true
	$AttackHitboxRight.monitoring = true
	
func play_anim(animation):
	anim.play(animation)

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != PlayerID:
		$CursorPointer.visible = false
		return
		
	lifetime -= delta * time_multiplier
	var direction = Input.get_axis("Left", "Right")
	
	if not is_on_floor():
		var mul: float = 1
		if gravity_counter1 > 0:
			mul = 0.5
		elif gravity_counter2 > 0:
			mul = 2
		velocity.y += mul * gravity * delta * (time_multiplier ** 2)
	
	gravity_counter1 -= delta
	gravity_counter2 -= delta
		
	$CursorPointer.look_at(get_viewport().get_mouse_position())	

	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
		active_attack_hitbox = $AttackHitboxLeft
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		active_attack_hitbox = $AttackHitboxRight
		
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * time_multiplier 

	if Input.is_action_just_pressed("Attack") and is_on_floor():
		anim.play("Attack")
		
	if Input.is_action_just_pressed("RangeAttack"):
			throw_press_duration = 0.0
		
	if throw_cooldown <= 0.0 and Input.is_action_just_released("RangeAttack"):
		var throw_power = min(MAX_THROW_DURATION, throw_press_duration) + 1.0
		add_projectile.rpc(throw_power)
		throw_cooldown = THROW_COOLDOWN
		#print("Range attack pressed for:", throw_press_duration, "seconds")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED * time_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var animation = "Idle"
	if velocity.y != 0:
		if velocity.y < 0:
			animation = "Jump"
		else:
			animation = "Fall"
	elif Input.is_action_pressed("Attack"):
		animation = "Attack"
	else:
		if velocity.x == 0:
			animation = "Idle"
		else:
			animation = "Run"
	
	play_anim(animation)
	throw_press_duration += delta
	throw_cooldown -= delta
	move_and_slide()
	
func on_time_multiplier_changed(new_time_multiplier):
	time_multiplier = new_time_multiplier
	anim.speed_scale = time_multiplier
