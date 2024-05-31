extends Node2D

var coin_preload = preload("res://Scn/Collectibles/coin.tscn")


func _ready():
	Signals.connect("enemy_died", Callable(self, "_on_enemy_died"))
	
	
func _on_enemy_died(enemy_position):
	for i in randf_range(1,3): # Обычный for 5 раз пишеться как i in 5
		coin_spawn(enemy_position) # Делаем так чтобы в функцию спавна монет подавалась позиция врага
	
func coin_spawn(pos):
	var coin = coin_preload.instantiate() #instantiate() создает копию
	coin.position = pos
	call_deferred("add_child", coin) # Создает монетку
