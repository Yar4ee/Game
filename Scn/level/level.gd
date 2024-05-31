extends Node2D

@onready var light = $Sun
@onready var pointlight = $PointLight2D
@onready var player = $Player/gamer

var next_screen = preload("res://Scn/DangeonLevel/dangeon_level.tscn")

enum { # Список состояний дня в игре (пока меняютья по таймеру DayNight каждые 20 сек но поменять на пару минут)
	MORNING,
	DAY, # списки из состояний выглядят как обычный масив [0,1,2,3] Где каждое число это состояние в списке 
	EVENING,
	NIGHT
}

var state = MORNING

func _ready(): # _ready означет что при запуске запуститься жта функция и дальше рабоать будет
	light.enabled = true
	morning_state() # Для запуска света, так как при работе со сценой enabled = false (чтобы не раотать в полной темноте)
	


func morning_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.2, 30)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointlight, "energy", 0, 30)

func evening_state() :
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.97, 50)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointlight, "energy", 1.5, 50)


func _on_day_night_timeout(): #Когда таймер закончился меняем время суток
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	if state < 3: 
		state += 1 
	else: # Если была ночь то переходим опять на утро
		state = MORNING # или 0





func _on_change_level_body_entered(body):
	if body.name == 'gamer':
		get_tree().change_scene_to_file("res://Scn/DangeonLevel/dangeon_level.tscn")
