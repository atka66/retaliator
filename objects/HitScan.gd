extends Spatial

var origin
var angle
const meshMaxLength = 400
export(float) var alpha = 1.0

func _ready():
	rotation = angle
	$RayCast.force_raycast_update()
	var meshMaterial = $Mesh.mesh.material.duplicate()
	var mesh = $Mesh.mesh.duplicate()
	if $RayCast.get_collider() == null:
		mesh.height = meshMaxLength
		print("miss")
	else:
		print("hit")
		mesh.height = translation.distance_to($RayCast.get_collision_point())
	$Mesh.translation.y = -mesh.height / 2
	$Mesh.mesh = mesh
	$Mesh.mesh.material = meshMaterial

func _process(delta):
	$Mesh.mesh.material.set_shader_param("a", alpha)
