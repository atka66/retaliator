extends KinematicBody

enum State {
	SLEEPING, # unalerted
	SEARCHING, # alerted, approaching target
	ATTACKING, # alerted, attacking target
	DEAD # dead
}
const fov = 180
var speed = 4
var hp = 10
var velocity = Vector3.ZERO

var map_player = null
var map_nav = null

export(bool) var alive = true
export(Vector3) var lookAngle = Vector3(0, 0, -1)
export(State) var state = State.SLEEPING
var target = null

func _ready():
	map_player = get_tree().get_nodes_in_group('player')[0]
	map_nav = get_tree().get_nodes_in_group('navigation')[0]

func _process(delta):
	if state == State.SLEEPING:
		checkFront()
	if state == State.SEARCHING:
		approachTarget()
	if state == State.ATTACKING:
		approachTarget()
	determineSprite()

func _physics_process(delta):
	# reset to 0 on y axis
	transform.origin.y = 0
	velocity.y = 0
	# apply movement
	#velocity.y -= gravity
	velocity = move_and_slide(velocity, Vector3.UP)
	# friction
	velocity.x *= Global.friction
	velocity.z *= Global.friction

func checkFront():
	if target == null && isInSight(map_player):
		target = map_player
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
		moveTowards(target.translation)
	else:
		state = State.SLEEPING

func moveTowards(targetPosition):
	var path = map_nav.get_simple_path(translation, targetPosition)
	if path.size() > 1:
		var toTargetVec = path[1] - translation
		lookAngle = toTargetVec.normalized()
		velocity += lookAngle * speed

func determineSprite():
	if state == State.DEAD:
		$Sprite.frame = 4
	else:
		var spriteAngle = lookAngle.normalized().dot((map_player.translation - translation).normalized())
		if spriteAngle > 0.5:
			$Sprite.frame = 0
		elif spriteAngle > -0.5:
			if lookAngle.normalized().cross((map_player.translation - translation).normalized()).y < 0:
				$Sprite.frame = 1
			else:
				$Sprite.frame = 3
		else:
			$Sprite.frame = 2

func getHitBy(origin, damage):
	velocity += origin.translation.direction_to(translation) * damage * 10
	hurt(damage)
	target = origin
	if state == State.SLEEPING:
		state = State.ATTACKING

func hurt(damage):
	if state != State.DEAD:
		hp -= damage
		if hp < 0:
			hp = 0
			die()

func die():
	state = State.DEAD
	alive = false
	$CollisionShape.disabled = true
