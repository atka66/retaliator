extends KinematicBody

enum State {
	SLEEPING, # unalerted
	SEEKING, # alerted, searching
	ATTACKING, # alerted, target in sight
	DEAD # dead
}
const fov = 160
var speed = 10

export(bool) var alive = true
export(Vector3) var lookAngle = Vector3(0, 0, -1)
export(State) var state = State.SLEEPING
var target = null

func _ready():
	pass # Replace with function body.

func _process(delta):
	if state == State.SLEEPING:
		lookForward()
	if state == State.SEEKING:
		lookForTarget()

func lookForward():
	for player in get_tree().get_nodes_in_group('player'):
		var toPlayerVec = player.translation - translation
		if acos(toPlayerVec.normalized().dot(lookAngle)) < deg2rad(fov / 2):
			$Eyes.cast_to = toPlayerVec
			if $Eyes.is_colliding():
				if $Eyes.get_collider() == player:
					target = player
					state = State.SEEKING

func lookForTarget():
	if target != null && target.alive:
		moveTowards(target)
		
func moveTowards(target):
	var toTargetVec = target.translation - translation
	move_and_slide(toTargetVec.normalized() * speed, Vector3.UP)
