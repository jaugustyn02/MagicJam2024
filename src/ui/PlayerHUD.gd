extends Control

var characterNode
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TimeBar.update_lifetime(characterNode.lifetime)
	$TimeCounter.update_lifetime(characterNode.lifetime)
	
	pass
