extends Area2D


func _on_body_entered(body):
	if "gravity_counter1" in body:
		var tween1 = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween1.tween_property(self,"position", position - Vector2(0, 20), 0.5)
		tween2.tween_property(self, "modulate:a", 0, 0.5)
		tween1.tween_callback(queue_free)
		body.gravity_counter1 = 8
		body.gravity_counter2 = -1
		get_parent().count -= 1
	else:
		queue_free()
