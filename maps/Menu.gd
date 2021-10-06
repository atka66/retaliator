extends Node2D

func _input(event):
	if (event.is_action_pressed("ui_accept")):
		get_tree().change_scene("res://maps/Map1.tscn")
	if (event.is_action_pressed("ui_cancel")):
		get_tree().quit()
