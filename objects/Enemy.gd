extends KinematicBody

enum State {
	SLEEPING, # unalerted
	SEARCHING, # alerted, approaching target
	ATTACKING, # alerted, attacking target
	DEAD # dead
}
const fov = 180
var speed = 10

export(bool) var alive = true
export(Vector3) var lookAngle = Vector3(0, 0, -1)
export(State) var state = State.SLEEPING
var target = null

func _ready():
	pass # Replace with function body.

func _process(delta):
	if state == State.SLEEPING:
		checkFront()
	if state == State.SEARCHING:
		approachTarget()
	if state == State.ATTACKING:
		approachTarget()

func checkFront():
	for player in get_tree().get_nodes_in_group('player'):
		if isInSight(player):
			target = player
			state = State.ATTACKING

func isInSight(entity):
	var toEntityVec = entity.translation - translation
	if acos(toEntityVec.normalized().dot(lookAngle)) < deg2rad(fov / 2):
		$Eyes.cast_to = toEntityVec
		if $Eyes.is_colliding() && $Eyes.get_collider() == entity:
			return true
	return false

func approachTarget():
	if target != null && target.alive:
		if isInSight(target):
			moveTowards(target.translation)
		else:
			moveTowards(target.translation)
	else:
		state = State.SLEEPING

func moveTowards(targetPosition):
	var toTargetVec = targetPosition - translation
	lookAngle = move_and_slide(toTargetVec.normalized() * speed, Vector3.UP).normalized()
