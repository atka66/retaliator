extends Area

var origin
var direction = Vector3.ONE
var speed = 60
var damage = 1

func _physics_process(delta):
	#look_at(transform.origin + direction, Vector3.UP)
	transform.origin += direction * delta * speed

func _on_Projectile_body_entered(body):
	if body != origin:
		if body.has_method("getHit"):
			body.getHit(origin, damage)
		var impactProjectile = Res.ImpactProjectile.instance()
		impactProjectile.translation = translation
		get_parent().add_child(impactProjectile)
		queue_free()
