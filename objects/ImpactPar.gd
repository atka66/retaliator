extends Particles

export(Color) var color = Color.white

func _ready():
	process_material = process_material.duplicate()
	process_material.color = color
	emitting = true

func _process(delta):
	if !emitting:
		queue_free() 
