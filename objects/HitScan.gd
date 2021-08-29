extends RayCast

var origin

const meshMaxLength = 400

func _ready():
	add_exception(origin)
	$Spatial.rotation = cast_to
	if get_collider() == null:
		$Spatial/Mesh.mesh.height = meshMaxLength
		print("miss")
	else:
		print("hit")
		$Spatial/Mesh.mesh.height = translation.distance_to(get_collision_point()) / 2
	$Spatial/Mesh.translation.y = -$Spatial/Mesh.mesh.height / 2
