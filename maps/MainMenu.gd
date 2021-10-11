extends Node2D

var menuState = 0
var slotChoice = 0

func _ready():
	$Anim.play("load")
	$State0Container/Anim.play("in")
	#$State1Container/Anim.play("out")
	pass

func _input(event):
	if $Conductor.playing:
		if (event.is_action_pressed("ui_accept")):
			playStateAnim(menuState, 'out')
			menuState += 1
			playStateAnim(menuState, 'in')
		if (event.is_action_pressed("ui_cancel")):
			playStateAnim(menuState, 'out')
			menuState -= 1
			playStateAnim(menuState, 'in')
			
		
		if menuState > 2:
			get_tree().change_scene("res://maps/Map1.tscn")
		if menuState < 0:
			get_tree().quit()
			
		if menuState == 1:
			if (event.is_action_pressed('ui_up')):
				slotChoice = (slotChoice + 5) % 3
			if (event.is_action_pressed('ui_down')):
				slotChoice = (slotChoice + 1) % 3

func _on_Conductor_beat(beat):
	if beat % 2 == 0:
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

func playStateAnim(state, anim):
	var nodeName = 'State' + str(state) + 'Container/Anim'
	if has_node(nodeName):
		get_node(nodeName).play(anim)
