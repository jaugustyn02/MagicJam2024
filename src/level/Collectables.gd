extends Node

var Hourglass = preload("res://src/collectibles/hourglass.tscn")
const maxC: int = 3
var count: int
var rng = RandomNumberGenerator.new()

func _ready():
	count = 0


func _process(delta):
	pass


func _on_timer_timeout():
	if count < maxC:
		var new_hour = Hourglass.instantiate()
		new_hour.position = Vector2(rng.randi() % 900 + 50, rng.randi() % 600 + 20)
		add_child(new_hour)
		count += 1
