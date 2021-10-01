extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if (event.is_action_pressed("ui_accept")):
		get_tree().change_scene("res://maps/Map1.tscn")
	if (event.is_action_pressed("ui_cancel")):
		get_tree().quit()
