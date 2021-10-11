extends Node2D

var menuState = 0
var slotChoice = 0
var mapChoice = 0

var locked = false

func _ready():
	$Anim.play("load")
	$State0Container/Anim.play("in")
	pass

func _input(event):
	if $Conductor.playing && !locked:
		if (event.is_action_pressed("ui_accept")):
			next()
		if (event.is_action_pressed("ui_cancel")):
			prev()

		if (event.is_action_pressed('ui_up')):
			if menuState == 1:
				slotChoice = (slotChoice + 5) % 3
			if menuState == 2:
				mapChoice = (mapChoice + 9) % 5
		if (event.is_action_pressed('ui_down')):
			if menuState == 1:
				slotChoice = (slotChoice + 1) % 3
			if menuState == 2:
				mapChoice = (mapChoice + 1) % 5

func next():
	if menuState == 2:
		locked = true
		$Anim.play("fadeout")
	if menuState == 0:
		$TitleContainer/Anim.play('rise')
	playStateAnim(menuState, 'out')
	menuState += 1
	playStateAnim(menuState, 'in')

func prev():
	if menuState == 0:
		get_tree().quit()
	if menuState == 1:
		$TitleContainer/Anim.play('sink')
	playStateAnim(menuState, 'out')
	menuState -= 1
	playStateAnim(menuState, 'in')

func _on_Conductor_beat(beat):
	if beat % 2 == 0 && !locked:
		$Anim.play("beat")
		$Anim.seek(0)
		
	if menuState == 0:
		var crosshair = Res.CrosshairScene.instance()
		crosshair.position = Vector2(0, 12)
		crosshair.width = 320
		$State0Container.add_child(crosshair)
	if menuState == 1:
		var crosshair = Res.CrosshairScene.instance()
		crosshair.position = Vector2(0, (slotChoice * 128) + 12)
		crosshair.width = 192
		$State1Container.add_child(crosshair)
	if menuState == 2:
		var crosshair = Res.CrosshairScene.instance()
		crosshair.position = Vector2(0, (mapChoice * 64) + 12)
		crosshair.width = 192
		$State2Container.add_child(crosshair)

func playStateAnim(state, anim):
	var nodeName = 'State' + str(state) + 'Container/Anim'
	if has_node(nodeName):
		get_node(nodeName).play(anim)

func proceedToMap():
	get_tree().change_scene("res://maps/Map1.tscn")
