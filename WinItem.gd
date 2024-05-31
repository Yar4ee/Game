extends CharacterBody2D


func _on_detector_body_entered(body):
	var tween = get_tree().create_tween() # Переменная для анимации исчезания монетки после ее подбора
	tween.parallel().tween_property(self, "velocity", Vector2(0,-150), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5) # Paeallel позволяет нам анимировать одноверемнно 2 параметра для одной переменной tween
	await get_tree().create_timer(0.5).timeout
	queue_free()
