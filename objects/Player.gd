extends KinematicBody

var ConductorNode

var speed = 5
var velocity = Vector3.ZERO

var camera_anglev = 0
var mouseSensHor = 0.3
var mouseSensVer = mouseSensHor * 0.8

var bobbingRotation = 0
var alive = true

var selectedWeapon = 0
export(bool) var weaponBusy = false
var ammo = Global.shotgun_ammo_cap

func _ready():
	ConductorNode = get_tree().get_nodes_in_group('conductor')[0]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# reset to 0 on y axis
	transform.origin.y = 0
	velocity.y = 0
	# input movement
	if Global.gameCntdwn < 1: 
		if Input.is_action_pressed("forward"):
			velocity += -transform.basis.z * speed
		if Input.is_action_pressed("back"):
			velocity += transform.basis.z * speed
		if Input.is_action_pressed("strafe_left"):
			velocity += -transform.basis.x * speed
		if Input.is_action_pressed("strafe_right"):
			velocity += transform.basis.x * speed
	# apply movement
	#velocity.y -= gravity
	velocity = move_and_slide(velocity, Vector3.UP)
	# friction
	velocity.x *= Global.friction
	velocity.z *= Global.friction
	# camera tilt on strafe
	$Camera.rotation_degrees.z = -velocity.rotated(Vector3.UP, -rotation.y).x / 8

func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		$Camera.rotation.x += -deg2rad(movement.y * mouseSensVer)
		rotation.y += -deg2rad(movement.x * mouseSensHor)
		$Camera.rotation.x = max(min($Camera.rotation.x, 1.5), -1.5)
		
	if Global.gameCntdwn < 1:
		if !weaponBusy:
			if event.is_action_pressed("shoot"):
				if ConductorNode.getBeatCheckResult(0):
					if ammo > 0:
						shoot()
					else:
						$Camera/Visor/AmmoAnim.play("empty")
						$Camera/CrosshairAnim.play("fail")
				else:
					$Camera/CrosshairAnim.play("fail")
			if event.is_action_pressed("reload"):
				if ConductorNode.getBeatCheckResult(0):
					reload()
				else:
					$Camera/CrosshairAnim.play("fail")
	else:
		if event.is_action_pressed("shoot"):
			if !ConductorNode.playing:
				ConductorNode.playMute()
				$Camera/Visor/ReadyLabel.time_disappear()

func _process(delta):
	if !weaponBusy:
		if Input.is_key_pressed(KEY_0):
			switchWeapon(0)
		if Input.is_key_pressed(KEY_1):
			switchWeapon(1)

	positionCamera()
	DEBUGTEXT()
	renderVisor()

func positionCamera():
	var planarVel = velocity
	planarVel.y = 0
	var bobbingVel = planarVel.length() / 200
	var bobbingIntensity = min(16, bobbingVel * 100)
	bobbingRotation += bobbingVel
	$Camera/Weapon.rect_position.x = sin(bobbingRotation) * bobbingIntensity
	$Camera/Weapon.rect_position.y = (-cos(bobbingRotation * 2) * bobbingIntensity) / 2

func shoot():
	ammo -= 1

	velocity += transform.basis.z * 20
	$Camera/WeaponAnim.play("shoot")
	
	for i in range(5):
		var hitScan = Res.HitScan.instance()
		hitScan.translation = translation
		hitScan.translation.y += 3
		var angle = $Camera.rotation
		angle.y = rotation.y + ((randf() / 20) - 0.025)
		angle.x += deg2rad(91)
		hitScan.angle = angle
		hitScan.origin = self
		hitScan.damage = 1
		get_parent().add_child(hitScan)

func reload():
	ammo = Global.shotgun_ammo_cap
	$Camera/WeaponAnim.play("reload")

func DEBUGTEXT():
	pass

func switchWeapon(weapon):
	if selectedWeapon != weapon:
		selectedWeapon = weapon


func _on_Conductor_beat(position):
	if Global.gameCntdwn > 0:
		if Global.gameCntdwn > 1:
			showCount(str(Global.gameCntdwn - 1), 8)
			$Camera/WeaponAnim.play("cntdwn" + str(6 - Global.gameCntdwn))
		if Global.gameCntdwn == 1:
			showCount("go!", 12)
			$Camera/WeaponAnim.play("draw")
		
		Global.gameCntdwn -= 1
		if Global.gameCntdwn < 1:
			ConductorNode.playUnmute()
	else:
		if !$Camera/CrosshairAnim.is_playing():
			$Camera/CrosshairAnim.play("pulse")
	var crosshair = Res.CrosshairScene.instance()
	get_tree().get_current_scene().add_child(crosshair)

func showCount(cnt, size):
	var label = Res.CustomLabelScene.instance()
	label.position = Vector2(640, 224)
	label.text = cnt
	label.fontSize = size
	#label.outline = true
	label.aliveTime = 0.3
	label.alignment = Label.ALIGN_CENTER
	$Camera/Visor.add_child(label)

func renderVisor():
	if Global.gameCntdwn == 0:
		$Camera/Visor/AmmoLabel.set_text(str(ammo))
		$Camera/Visor/AmmoSlashLabel.set_text('/')
		$Camera/Visor/AmmoCapLabel.set_text(str(Global.shotgun_ammo_cap))
