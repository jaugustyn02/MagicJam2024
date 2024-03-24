extends Label

var lifetime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_lifetime(lt: float) -> void:
	lifetime = lt
	text = "HP: " + str(snapped(lifetime, 0.1)) + "s"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
