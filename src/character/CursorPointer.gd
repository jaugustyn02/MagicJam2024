extends Node2D

@export var PlayerID: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().get_multiplayer_authority() == PlayerID:
		look_at(get_viewport().get_mouse_position())
	pass
