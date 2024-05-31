extends Area2D




func _on_body_entered(body):
	if body.name == "gamer":
		var tween = get_tree().create_tween() # Переменная для анимации исчезания монетки после ее подбора
		var tween1 = get_tree().create_tween() # Буду использовать для зменения прозрачности
		tween.tween_property(self, "position", position - Vector2(0, 25), 0.3) # Значения в скобках: 1 - предмет; 2 - что меняем; 3 - на сколько меняем; 4 - за сколько меняем (в секундах)
		tween1.tween_property(self, "modulate:a", 0, 0.3) # В параметрах visabillyty за прозрачность отвечает параметр A
		tween.tween_callback(queue_free) # ждем пока закончиться анимация в переменной tween и уничтожаемся
		body.gold += 1
	
