extends Node2D

export(int) var slotId = 0
export(int) var percent = 0

func _ready():
	$SlotLabel.set_text('slot ' + str(slotId))
	$CompletionLabel.set_text(str(percent) + '%')
