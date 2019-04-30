extends ParticleCharacter

class BoneAttachmentInfo:
	var bone_num
	var closest_cluster
	var inv_cluster_offset_transform

var attachment_info : Array = []

var bone_attachments : Dictionary = {
	"Leg.L" : "leg_left",
	"Leg.R" : "leg_right",
	"LowerArm.L" : "hand_left",
	"LowerArm.R" : "hand_right"
	}

const SWING_SPEED_MAX = 0.8
const SWING_PULL_DOWN_SPEED = 0.5
	
onready var swing_active = false
onready var swing_acceleration = Vector3()
onready var swing_velocity = Vector3()

onready var top_colour : Color = Color(0.34, 0.9, 0.76, 1.0)
onready var bottom_colour : Color = Color(0, 0.21, 0.55, 1.0)

func find_closest_cluster(point : Vector3):
	var result = -1
	
	var cluster_positions : PoolVector3Array = self.particle_body_model.clusters_positions
	
	if cluster_positions.size() > 0:
		var closest_dist_sqr = 1000000
		var cluster_id = 0
		for position in cluster_positions:
			var dist_sqr  = (position - point).length_squared()
			if dist_sqr < closest_dist_sqr:
				closest_dist_sqr = dist_sqr
				result = cluster_id
			cluster_id += 1
	
	return result

func get_bone_rest_global_pose(skeleton : Skeleton, id):
	var bone_transform : Transform = skeleton.get_bone_transform(id)
	var global_bone_pose : Transform = skeleton.get_bone_global_pose(id)
	
	var inv_global_bone_pose : Transform = global_bone_pose.affine_inverse()
	
	var inv_rest_global_pose : Transform = inv_global_bone_pose * bone_transform
	var rest_global_pose : Transform = inv_rest_global_pose.affine_inverse()
	return rest_global_pose

func find_group(name : String):
	var result = -1
	for group_num in range(group_count):
		var group_name : String = self.get("group_"+String(group_num)+"/name")
		if group_name == name:
			result = group_num
			break
	return result
		
func init_bone_attachments():
	var skel : Skeleton = $player_controller/Armature/Skeleton
	
	var bone_names : Array = bone_attachments.keys()
	var bone_groups : Array = bone_attachments.values()
	
	for attachment_num in range(bone_attachments.size()):
		var bone_name = bone_names[attachment_num]
		var group_name = bone_groups[attachment_num]
		
		var bone_num = skel.find_bone(bone_name)
		var group_num = find_group(group_name)
		
		if (bone_num != -1) and (group_num != -1):
			var rest_global_pose = get_bone_rest_global_pose(skel, bone_num)
			var closest_cluster = find_closest_cluster(rest_global_pose.origin)
			if closest_cluster != -1:
				var global_cluster_transform = Transform()
				global_cluster_transform.origin = self.particle_body_model.clusters_positions[closest_cluster]
				var inv_rest_global_pose = rest_global_pose.affine_inverse()
				var cluster_offset_transform : Transform = inv_rest_global_pose * global_cluster_transform
				var inv_cluster_offset_transform = cluster_offset_transform.affine_inverse()
				
				var info : BoneAttachmentInfo = BoneAttachmentInfo.new()
				info.bone_num = bone_num
				info.closest_cluster = closest_cluster
				info.inv_cluster_offset_transform = inv_cluster_offset_transform
				attachment_info.append(info)

func update_bone_attachments(commands : ParticleBodyCommands):
	var skel : Skeleton =  $player_controller/Armature/Skeleton
	for info in attachment_info:
		var rigid_transform : Transform = commands.get_rigid_transform(info.closest_cluster)
		var inv_skeleton_global_pose = skel.global_transform.affine_inverse()
		var bone_global_pose = inv_skeleton_global_pose * rigid_transform * info.inv_cluster_offset_transform
		skel.set_bone_global_pose(info.bone_num, bone_global_pose)

# Called when the node enters the scene tree for the first time.
func _ready():
	var body_material : ShaderMaterial = $Body.get_surface_material(0)
	body_material.set_shader_param("top_color", top_colour)
	body_material.set_shader_param("bottom_color", bottom_colour)	
	
	init_bone_attachments()
	
	$player_controller/camera_base.global_transform.basis = $player_controller/camera_base.transform.basis

func _physics_process(delta):
	pass

func _commands_process(commands):
	var delta = get_physics_process_delta_time()
	if swing_active:
		#var origin_particle = get_group_origin_particle("inner_body")
		
		var body_group_num = find_group("swing")
		
		var body_particles = get("group_"+String(body_group_num)+"/particles")
		
		for particle in body_particles:
			var current_velocity = commands.get_particle_velocity(particle)
			var dv = swing_acceleration*delta
			#dv.y += -1.6
			var new_velocity = current_velocity+dv
			
			#limit velocity in xz plane
			var limitted_velocity = new_velocity
			limitted_velocity.y = 0
			
			var speed = limitted_velocity.length()
			
			if speed > SWING_SPEED_MAX:
				limitted_velocity.normalized()
				new_velocity = Vector3(limitted_velocity.x*SWING_SPEED_MAX, new_velocity.y, limitted_velocity.z*SWING_SPEED_MAX)
				
			#add some velocity to pull character down a bit
			new_velocity += Vector3(0, -SWING_PULL_DOWN_SPEED, 0)
			swing_velocity = new_velocity
			commands.set_particle_velocity(particle, new_velocity)

func _post_step_commands_process(commands):
	update_bone_attachments(commands)
	
func get_core_area_name():
	var core_group_num = get_core_group()
	if core_group_num == -1:
		return ""
	else:
		var core_shape : CollisionShape = get_group_shape(core_group_num)
		return core_shape.get_parent().name
		
func get_camera():
	return $player_controller/camera_base/camera_rot/camera
