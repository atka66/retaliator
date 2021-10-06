extends Node2D

export (bool) var sub = false

func _ready():
	$Anim.play("crosshair")

func _on_Anim_animation_finished(anim_name):
	queue_free()
