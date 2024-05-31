extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Стандартная гравитация вшитая в годот

func _ready():
	var tween = get_tree().create_tween() # Переменная для анимации исчезания монетки после ее подбора
	tween.parallel().tween_property(self, "velocity", Vector2(randi_range(-70,70),-150), 0.3) #randi_range дает рандомное число в указанном диапозоне

func _physics_process(delta):
	if not is_on_floor(): # если в воздухе
		velocity.y += gravity * delta # то на персонажа дествует гравитация
	else:
		velocity.x = 0
	move_and_slide()


func _on_detector_body_entered(body):
	var tween = get_tree().create_tween() # Переменная для анимации исчезания монетки после ее подбора
	tween.parallel().tween_property(self, "velocity", Vector2(0,-150), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5) # Paeallel позволяет нам анимировать одноверемнно 2 параметра для одной переменной tween
	await get_tree().create_timer(0.5).timeout
	body.gold += 1
	queue_free()
