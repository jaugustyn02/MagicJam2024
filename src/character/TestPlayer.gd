extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -800.0
const INITIAL_LIFETIME = 180.0
const SWORD_DAMAGE = 10.0

@export var lifetime: float = INITIAL_LIFETIME

var lifetime2: float = INITIAL_LIFETIME

var time_multiplier: float = 1.0
var attack: float = 0
var PlayerID: int
var is_attacking: bool = false
var is_attack_hitbox_active: bool = false
var pixel_hack_stage: int = 0
var locked_attack_direction: int = 0

@onready var anim = get_node("AnimationPlayer")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	PlayerID = multiplayer.get_unique_id()
	
	$PlayerHitbox.monitoring = true
	$AttackHitbox.collision_layer = 0
	$AttackHitbox.collision_mask = 0
	
func play_anim(animation):
	if animation != null:
		anim.play(animation)

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != PlayerID:
		return
		
	lifetime -= delta * time_multiplier
	lifetime2 -= delta * time_multiplier
	var direction = Input.get_axis("Left", "Right")
		
	if not is_on_floor():
		velocity.y += gravity * delta * (time_multiplier ** 2)
		
	if !is_attacking:
		change_direction(direction)
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * time_multiplier 

	if Input.is_action_just_pressed("Attack") and !is_attacking:
		change_direction(-1 if (get_local_mouse_position().x < 0) else 1)
		is_attacking = true
		anim.play("Attack")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED * time_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var animation = "Idle"
	if is_attacking and anim.is_playing():
		if anim.current_animation_position > 0.2:
			if pixel_hack_stage == 0:
				$AttackHitbox.position.x += 1
				pixel_hack_stage = 1
			elif pixel_hack_stage == 1:
				$AttackHitbox.position.x -= 1
				pixel_hack_stage = 2
			$AttackHitbox.collision_layer = 1
		animation = null
		is_attacking = true
	elif velocity.y != 0:
		is_attacking = false
		$AttackHitbox.collision_layer = 0
		pixel_hack_stage = 0
		if velocity.y < 0:
			animation = "Jump"
		else:
			animation = "Fall"
	else:
		is_attacking = false
		$AttackHitbox.collision_layer = 0
		pixel_hack_stage = 0
		if velocity.x == 0:
			animation = "Idle"
		else:
			animation = "Run"
	
	play_anim(animation)
	move_and_slide()
	
func change_direction(direction):
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
		$AttackHitbox.scale.x = -1
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		$AttackHitbox.scale.x = 1
	
func on_time_multiplier_changed(new_time_multiplier):
	time_multiplier = new_time_multiplier
	anim.speed_scale = time_multiplier

func _on_player_hitbox_area_entered(area):
	if area != $AttackHitbox:
		lifetime -= SWORD_DAMAGE
