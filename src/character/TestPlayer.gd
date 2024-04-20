extends CharacterBody2D

signal end_game(player_id)

@export var projectile :PackedScene
@export var PlayerName :String

const SPEED = 400.0
const SWORD_DAMAGE = 3.0
const SPEAR_DAMAGE = 5.0
const JUMP_VELOCITY = -600
const INITIAL_LIFETIME = 180.0 

const MAX_THROW_DURATION = 0.5
const THROW_COOLDOWN = 0.5

var PlayerID: int
var throw_press_duration = 0.0
var throw_cooldown = 0.0

@export var lifetime: float = INITIAL_LIFETIME

var lifetime2: float = INITIAL_LIFETIME

var time_multiplier: float = 1.0
var attack: float = 0
var is_attacking: bool = false
var is_attack_hitbox_active: bool = false
var pixel_hack_stage: int = 0
var locked_attack_direction: int = 0

var dash_cooldown: float = 0.0
var is_dead: bool = false
var double_jump_available: bool = true

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

	$AttackHitbox.collision_layer = 0
	$AttackHitbox.collision_mask = 0
	
func play_anim(animation):
	if animation != null:
		anim.play(animation)

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != PlayerID:
		$CursorPointer.visible = false
		return
		
		
	lifetime -= delta * time_multiplier
	#if is_dead: 
		#return
		
	if lifetime <= 0.0 and !is_dead:
		end_game.emit(PlayerID)
		is_dead = true
		anim.play("Die")
		set_physics_process(false)
		return
	
	var direction = Input.get_axis("Left", "Right")
	
	if not is_on_floor():
		var mul: float = 1
		if gravity_counter1 > 0:
			mul = 0.5
		elif gravity_counter2 > 0:
			mul = 2
		velocity.y += mul * gravity * delta * (time_multiplier ** 2)
	else:
		double_jump_available = true
	
	gravity_counter1 -= delta
	gravity_counter2 -= delta
	
		
	if !is_attacking:
		change_direction(direction)
	
	$CursorPointer.look_at(get_viewport().get_mouse_position())	

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and (is_on_floor() or double_jump_available):
		if !is_on_floor():
			double_jump_available = false
		velocity.y = JUMP_VELOCITY * time_multiplier
			

	if Input.is_action_just_pressed("Attack") and !is_attacking and not Input.is_action_pressed("RangeAttack"):
		change_direction(-1 if (get_local_mouse_position().x < 0) else 1)
		is_attacking = true
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
	throw_press_duration += delta
	throw_cooldown -= delta
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

func take_damage(color):
	self.modulate = color
	await get_tree().create_timer(0.3).timeout
	self.modulate = Color.WHITE

func _on_player_hitbox_area_entered(area):
	if area != $AttackHitbox:
		if "playerNode2D" in area.get_parent():
			if area.get_parent().playerNode2D != self:
				lifetime -= SWORD_DAMAGE
				take_damage(Color.RED)
		else:
			lifetime -= SWORD_DAMAGE
			take_damage(Color.RED)
		
		
