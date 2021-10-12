extends KinematicBody

var MapNode
var ConductorNode
enum State {
	IDLE, # unalerted
	SEARCHING, # looking for target
	APPROACHING, # approaching target, potentionally attacking
	ATTACKING, # starting to attack target
}
const fov = 180
var speed = 3
var hp = 5
var velocity = Vector3.ZERO

var map_player = null
var map_nav = null

export(bool) var alive = true
export(Vector3) var lookAngle = Vector3(0, 0, -1)
export(State) var state = State.IDLE

var target = null
var aggroMap = {}

func _ready():
	MapNode = get_tree().get_nodes_in_group('conductor')[0]
	ConductorNode = get_tree().get_nodes_in_group('conductor')[0]
	ConductorNode.connect("beat", self, "_on_Conductor_beat")
	map_player = get_tree().get_nodes_in_group('player')[0]
	map_nav = get_tree().get_nodes_in_group('navigation')[0]

func _process(delta):
	# determine state
	if alive:
		if target == null:
			if state != State.IDLE:
				state = State.IDLE
			if isInSight(map_player) && !aggroMap.has(map_player):
				retaliate(map_player, 0)
		else:
			if state != State.ATTACKING:
				if isInSight(target):
					state = State.APPROACHING
				else:
					state = State.SEARCHING

		# act according to state
		if state == State.SEARCHING || state == State.APPROACHING:
			approachTarget()

	# other
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
		state = State.IDLE

func moveTowards(targetPosition):
	var path = map_nav.get_simple_path(translation, targetPosition)
	if path.size() > 1:
		var toTargetVec = path[1] - translation
		lookAngle = toTargetVec.normalized()
		velocity += lookAngle * speed

func determineSprite():
	if !alive:
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
		if state == State.ATTACKING:
			$Sprite.frame += 5

func getHit(origin, damage):
	velocity += origin.translation.direction_to(translation) * damage * 10
	hurt(damage)
	retaliate(origin, damage)

func hurt(damage):
	if alive:
		$HurtSound.play()
		hp -= damage
		if hp < 1:
			hp = 0
			die()

func die():
	alive = false
	$CollisionShape.disabled = true

func _on_Conductor_beat(beat):
	determineTarget()
	if alive:
		if state == State.ATTACKING:
			shoot()
			state = State.APPROACHING
		if state == State.APPROACHING:
			if randi() % 5 == 0:
				state = State.ATTACKING

func shoot():
	var projectile = Res.ProjectileScene.instance()
	projectile.origin = self
	projectile.transform = transform.translated(Vector3(0, 3, 0))
	projectile.direction = (target.translation - translation).normalized()
	MapNode.add_child(projectile)
	$ShootSound.play()

func retaliate(_target, _aggro):
	if aggroMap.has(_target):
		aggroMap[_target] += _aggro
	else:
		aggroMap[_target] = _aggro

func determineTarget():
	if aggroMap.size() > 0:
		var aggro = -1
		var _target = target
		for k in aggroMap.keys():
			if !k.alive:
				if _target == k:
					_target = null
				aggroMap.erase(k)
				continue
			if aggroMap[k] > aggro:
				aggro = aggroMap[k]
				_target = k
		target = _target
