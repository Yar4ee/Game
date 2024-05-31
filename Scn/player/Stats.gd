extends CanvasLayer

@onready var health_bar = $HealthBar

var max_health = 120
var health:
	set(value):
		health = clamp(value, 0, max_health) # Делает все тоже самое тоесть когда иземеняеться здоровье присменяет команды ниже, но ограничивает чтобы здоровье было не меньше 0 и не больше максимального 
		 
		health_bar.value = health

func _ready():
	health = max_health
	health_bar.max_value = health
	health_bar.value = health


func _on_health_regen_timeout():
	health += 3
