extends Node2D

export(String) var mapName = 'unnamed'

func _ready():
	$MapLabel.set_text(mapName)
