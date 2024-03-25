extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Fade_in")
	await get_tree().create_timer(2).timeout
	$AnimationPlayer.play("Fade_out")
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://src/game_management/MultiplayerController.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
