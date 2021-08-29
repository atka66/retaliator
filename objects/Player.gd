extends KinematicBody

var speed = 5
var friction = 0.9
#var gravity = 0.5

var velocity = Vector3.ZERO

var camera_anglev = 0
var mouseSensHor = 0.3
var mouseSensVer = mouseSensHor * 0.8

var bobbingRotation = 0
var alive = true
export(bool) var shooting = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# reset to 0 on y axis
	transform.origin.y = 0
	velocity.y = 0
	# input movement
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
	velocity.x *= friction
	velocity.z *= friction
	# camera tilt on strafe
	$Camera.rotation_degrees.z = -velocity.rotated(Vector3.UP, -rotation.y).x / 8

func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		$Camera.rotation.x += -deg2rad(movement.y * mouseSensVer)
		rotation.y += -deg2rad(movement.x * mouseSensHor)
		$Camera.rotation.x = max(min($Camera.rotation.x, 1.5), -1.5)
	if event.is_action_pressed("shoot"):
		if !shooting:
			shoot()

func _process(delta):
	positionCamera()
	DEBUGTEXT()

func positionCamera():
	var planarVel = velocity
	planarVel.y = 0
	var bobbingVel = planarVel.length() / 200
	var bobbingIntensity = min(16, bobbingVel * 100)
	bobbingRotation += bobbingVel
	$Camera/Weapon.rect_position.x = sin(bobbingRotation) * bobbingIntensity
	$Camera/Weapon.rect_position.y = (-cos(bobbingRotation * 2) * bobbingIntensity) / 2

func shoot():
	$Camera/Anim.play("shoot")
	var hitScan = Res.HitScan.instance()
	hitScan.translation = translation
	hitScan.translation.y += 3
	hitScan.cast_to = $Camera.rotation
	hitScan.cast_to.y = rotation.y
	hitScan.cast_to.x += deg2rad(91)
	hitScan.origin = self
	get_parent().add_child(hitScan)

func DEBUGTEXT():
	pass
