extends Node2D


func _on_win_deyector_body_entered(body):
	get_tree().change_scene_to_file("res://Scn/winCollectibles/win_sceen.tscn")
