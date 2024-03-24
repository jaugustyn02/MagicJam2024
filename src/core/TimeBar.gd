extends TextureProgressBar

var color
# Called when the node enters the scene tree for the first time.
func _ready():
	var sb = StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color(color)

func update_lifetime(lt: float) -> void:
	value = min(lt, 180.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
