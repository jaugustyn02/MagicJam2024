extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_lifetime(lt: float) -> void:
	value = min(lt, 180.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
