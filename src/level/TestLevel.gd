extends Node2D

var time: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 3:
		print("CHUJ")
		time = 0

func on_time_multiplier_changed(_mult):
	pass