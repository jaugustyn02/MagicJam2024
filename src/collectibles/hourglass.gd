extends Area2D

const added_value: float = 5.0
	
func _physics_process(delta):
	get_node("AnimatedSprite2D").play("Animation")
	
func _on_body_entered(body):
	if "lifetime" in body:
		var tween1 = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween1.tween_property(self,"position", position - Vector2(0, 20), 0.5)
		tween2.tween_property(self, "modulate:a", 0, 0.5)
		tween1.tween_callback(queue_free)
		body.lifetime = min(body.INITIAL_LIFETIME, body.lifetime + added_value)
		body.take_damage(Color.GREEN)
		get_parent().count -= 1
	else:
		queue_free()
