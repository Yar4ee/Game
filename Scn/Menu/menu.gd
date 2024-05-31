extends Node2D


func _on_quit_pressed():
	get_tree().quit() # по ветке закрываем все


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scn/level/level.tscn") # по ветке переходим на level
