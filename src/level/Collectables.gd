extends Node

var Hourglass = preload("res://src/collectibles/hourglass.tscn")
var BlueBall = preload("res://src/collectibles/gravity_ball_blue.tscn")
var RedBall = preload("res://src/collectibles/gravity_ball_red.tscn")

var newObject

const maxC: int = 3
var count: int
var rng = RandomNumberGenerator.new()
var timer: float = 15.0

func _ready():
	count = 0


func _process(delta):
	timer -= delta
	if timer < 0:
		timer = 5.0
		spawn_collectables.rpc()

@rpc("any_peer", "call_local")
func spawn_collectables():
	if count < maxC:
		var rand_number = rng.randi() % 3 
		if rand_number == 0:
			newObject = BlueBall.instantiate()
		elif rand_number == 1:
			newObject = Hourglass.instantiate()
		else:
			newObject = RedBall.instantiate()
			
		newObject.position = Vector2(rng.randi() % 900 + 50, rng.randi() % 600 + 20)
		add_child(newObject)
		count += 1
