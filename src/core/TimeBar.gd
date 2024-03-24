extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func lifetime_update(lt: float) -> void:
	value = max(lt, 180)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
