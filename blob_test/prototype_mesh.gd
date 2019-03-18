extends MeshInstance
class_name PrototypeMesh

func find_collision_shapes(node : Node, collision_shapes):
	if(node is CollisionShape):
		collision_shapes.append(node)

	for child in node.get_children():
		find_collision_shapes(child, collision_shapes)

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	if mesh:
		create_trimesh_collision()
		
	var collision_shapes = []
	find_collision_shapes(self, collision_shapes)
	
	for node in collision_shapes:
		# add a particle primitive body to create the collision
		# for the particle simulation
		var particle_mesh = ParticlePrimitiveBody.new()
		node.add_child(particle_mesh)

		var collision_shape : CollisionShape = node
		particle_mesh.shape = collision_shape.shape
	
	
#	var static_body = StaticBody.new()
#	add_child(static_body)
#
#	var collision_shape = CollisionShape.new()
#	static_body.add_child(collision_shape)	
#
#	if mesh as CubeMesh:
#		var cube_mesh : CubeMesh = mesh as CubeMesh
#		var box_shape = BoxShape.new()
#		box_shape.extents = cube_mesh.size*0.5
#		collision_shape.shape = box_shape
#	elif mesh as SphereMesh:
#		var sphere_mesh : SphereMesh = mesh as SphereMesh
#		var sphere_shape : SphereShape = SphereShape.new()
#		sphere_shape.radius = sphere_mesh.radius
#		collision_shape.shape = sphere_shape
#	elif mesh as CylinderMesh:
#		var cylinder_mesh : CylinderMesh = mesh as CylinderMesh
#		var cylinder_shape : CylinderShape = CylinderShape.new()
#		cylinder_shape.radius = cylinder_mesh.top_radius
#		cylinder_shape.height = cylinder_mesh.height
#		collision_shape.shape = cylinder_shape
#
#	var particle_primitive_body  = ParticlePrimitiveBody.new()
#	particle_primitive_body.shape = collision_shape.shape
#	static_body.add_child(particle_primitive_body)
	

		
