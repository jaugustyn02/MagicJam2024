extends Node

var Hourglass = preload("res://src/collectibles/hourglass.tscn")


const maxC: int = 3
var count: int
var rng = RandomNumberGenerator.new()

func _ready():
	count = 0
	rng.seed = hash(int(Time.get_unix_time_from_system()))


func _on_timer_timeout():
	if count < maxC:
		var new_object = Hourglass.instantiate()
		new_object.position = Vector2(rng.randi() % 1820 + 50, rng.randi() % 1040 + 20)
		add_child(new_object)
		count += 1
