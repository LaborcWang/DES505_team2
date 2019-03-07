tool # needed so it runs in editor
extends EditorScenePostImport

func post_import(scene):
	# do your stuff here
	print("Adding ParticlePrimitiveBody TriMesh Collision: "+scene.name)


	print("find mesh instances")
	var mesh_instances = []
	find_mesh_instances(scene, mesh_instances)
	
	#add collision to all mesh instances
	for mesh_instance in mesh_instances:
		mesh_instance.create_trimesh_collision()

	var collision_shapes = []

	print("find collision shapes")
	find_collision_shapes(scene, collision_shapes)
	
	for node in collision_shapes:
		# add a particle primitive body to create the collision
		# for the particle simulation
		var particle_mesh = ParticlePrimitiveBody.new()
		node.add_child(particle_mesh)
		particle_mesh.set_owner(scene)

		var collision_shape : CollisionShape = node
		var shape = collision_shape.shape.duplicate()
		particle_mesh.shape = collision_shape.shape
	
	return scene # remember to return the imported scene


func find_mesh_instances(node : Node, mesh_instances):

	if(node is MeshInstance):
		mesh_instances.append(node)

	for child in node.get_children():
		find_mesh_instances(child, mesh_instances)

func find_collision_shapes(node : Node, collision_shapes):

	if(node is CollisionShape):
		collision_shapes.append(node)

	for child in node.get_children():
		find_collision_shapes(child, collision_shapes)


