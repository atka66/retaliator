extends Area

var origin
var direction = Vector3.ONE
var speed = 60
var damage = 4

func _physics_process(delta):
	#look_at(transform.origin + direction, Vector3.UP)
	transform.origin += direction * delta * speed

func _on_Projectile_body_entered(body):
	if body != origin:
		if body.has_method("hurt"):
			body.hurt(damage)
		queue_free()
