extends Spatial

var origin
var angle
var damage = 1
const meshMaxLength = 400
export(float) var alpha = 1.0

func _ready():
	rotation = angle
	$RayCast.force_raycast_update()
	var meshMaterial = $Mesh.mesh.material.duplicate()
	var mesh = $Mesh.mesh.duplicate()
	
	var collider = $RayCast.get_collider()
	if collider == null:
		mesh.height = meshMaxLength
	else:
		var collPoint = $RayCast.get_collision_point()
		mesh.height = translation.distance_to(collPoint)
		var impactPar = Res.ImpactPar.instance()
		impactPar.translation = collPoint
		if collider.is_in_group('enemy'):
			collider.getHitBy(origin, damage)
			impactPar.color = Color.red
		else:
			impactPar.color = Color.white
		get_parent().add_child(impactPar)
	$Mesh.translation.y = -mesh.height / 2
	$Mesh.mesh = mesh
	$Mesh.mesh.material = meshMaterial

func _process(delta):
	$Mesh.mesh.material.set_shader_param("a", alpha)
