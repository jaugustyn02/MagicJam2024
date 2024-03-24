extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$TimeController.gear_changed.connect($LevelManager.on_time_manager_gear_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

