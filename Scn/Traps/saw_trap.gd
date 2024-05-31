extends CharacterBody2D



func _on_detector_body_entered(body):
	get_tree().change_scene_to_file("res://Scn/DangeonLevel/dangeon_level.tscn")
