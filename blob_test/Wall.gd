extends Spatial


# Called when the node enters the scene tree for the first time.
func _enter_tree():
	update_wall()

func update_wall():
	var box_shape : BoxShape = $StaticBody/CollisionShape.shape
	var cube_mesh : CubeMesh = $StaticBody/MeshInstance.mesh
	box_shape.extents = cube_mesh.size*0.5	
	if !$StaticBody/ParticlePrimitiveBody.shape:
		$StaticBody/ParticlePrimitiveBody.shape = box_shape
