extends Node2D

export (bool) var sub = false
export (int) var width = 0

func _ready():
	$LeftContainer.position.x -= width / 2
	$RightContainer.position.x += width / 2
	$Anim.play("crosshair")

func _on_Anim_animation_finished(anim_name):
	queue_free()
