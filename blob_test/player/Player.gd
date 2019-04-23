extends ParticleCharacter


var movement_speed = 2
var motion = Vector2()
const ROTATION_INTERPOLATE_SPEED = 10
const MOTION_INTERPOLATE_SPEED = 10
const CAMERA_INTERPOLATE_SPEED = 10
const GROUND_RAY_LENGTH = 0.6
const JUMP_SPEED = 15
const SPIN_JUMP_SPEED = 20
const CAMERA_ROTATION_SPEED = 0.01
const CAMERA_X_ROT_MIN = -20
const CAMERA_X_ROT_MAX = 45
const SELF_ROTATE_SPEED = 20
var is_grounded = false
var jump_started = false
var boost_zone = false
var boost_zone_speed = 30
var boost_zone_forward: Vector3
var boost_zone_entry : bool
var boost_zone_exit : bool
var camera_lookat : Vector3
var camera_x_rot = 0.00
var audio_Jumping
var audio_Squeezing
var audio_Moving
var audio_Landing
var JOYPAD_SENSITIVITY = 2
const JOYPAD_DEADZONE = 0.15
var squash = false
var squash_velocity : Vector3
var spin = false
var spin_timer
var spin_time = 30


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_lookat = get_core_frame_position()
	audio_Jumping = $Jump
	audio_Squeezing = $Squeeze
	audio_Landing = $Land
	audio_Moving = $Move
	
	audio_Jumping.stop()
	audio_Squeezing.stop()
	audio_Moving.stop()
	audio_Landing.stop()
	#pass

func _physics_process(delta):
	# called before the simulation is run
	joypad_input(delta)
	movement_and_jump(delta)
	boost_zone(delta)
	#boost_zone(delta)


#Control the parapmeter of particle group
func _commands_process(commands):
	#if get_tree().paused == true:
	#	movement_speed = 0
	#	return
	# called after the simulation is run
	var delta = get_physics_process_delta_time()
	var move_velocity : Vector3
	move_velocity = get_core_frame_velocity();
	if core_enabled:
		# set the xz in the velocity for player movement
		# leave y so gravity affects the body
		move_velocity.x = motion.x*movement_speed
		move_velocity.z = motion.y*movement_speed
	
		# change the y velocity to make that player jump
		if jump_started:
			if spin:
				move_velocity.y = SPIN_JUMP_SPEED
			else:
				move_velocity.y = JUMP_SPEED
		#change the y velocity when player is spinning and falling
		if spin && move_velocity.y < 0:
			move_velocity.y /= 4
		#rotate the character relative to the camera
		rotatePlayerToCamera(delta)
		#move_velocity = $camera_base.global_transform.basis.xform(move_velocity)
		move_velocity = get_node("../camera_base").global_transform.basis.xform(move_velocity)
		# set the desired velocity of the core
		move_core_frame(move_velocity, delta)	
	if squash:
		#print(squash_velocity)
		var extend_particle = get_group_origin_particle("Extend")
		var other_particle  = get_group_origin_particle("Core")
		if extend_particle != -1:
			commands.set_particle_velocity(extend_particle, squash_velocity)
			#commands.set_particle_velocity(other_particle, -squash_velocity)
			
	else:		
		pass
	
	# this makes the camera follow the player
	camera_lookat = camera_lookat.linear_interpolate( get_core_frame_position(), CAMERA_INTERPOLATE_SPEED * delta)
	#$camera_base.global_transform.origin = camera_lookat
	get_node("../camera_base").global_transform.origin = camera_lookat


func movement_and_jump(delta):
	# get the movement input
	var movement_input = Vector2()
	movement_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	movement_input.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	#smooth out input motion
	var motion_target = movement_input
	motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)
	
	var from = get_core_frame_position();
	var to = from + Vector3.DOWN*GROUND_RAY_LENGTH
	var result = get_world().direct_space_state.intersect_ray(from, to)
	if result:
		is_grounded = true
	else:
		is_grounded = false

	if is_grounded && Input.is_action_just_pressed("jump"):
		jump_started = true
	else:
		jump_started = false
	if Input.is_action_pressed("extend"):
		squash = true
		if(squash_velocity.y < 4):
			squash_velocity += Vector3(0,1,0).normalized() * movement_speed * delta
	else:
		squash_velocity = Vector3(0,1,0).normalized()
		squash = false
	#Press R to spin, spin state will last 30 seconds
	if Input.is_action_just_pressed("spin") && !spin:
		spin = true
		spin_timer = 0
	if spin:
		#print("Spin!")
		spin_timer += delta
		if spin_timer >= spin_time:
			spin = false
	if spin:
		self_rotate(delta)


func _input(event):
	if event is InputEventMouseMotion:
		camera_roate(event.relative.x,event.relative.y)


func camera_roate(x, y):
	#$camera_base.rotate_y( -x * CAMERA_ROTATION_SPEED )
	get_node("../camera_base").rotate_y( -x * CAMERA_ROTATION_SPEED )
	#$camera_base.orthonormalize() # after relative transforms, camera needs to be renormalized
	get_node("../camera_base").orthonormalize()
	camera_x_rot = clamp(camera_x_rot + y * CAMERA_ROTATION_SPEED,deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX) )
	#$camera_base/camera_rot.rotation.x =  camera_x_rot
	get_node("../camera_base/camera_rot").rotation.x =  camera_x_rot


func joypad_input(delta):
	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size()>0:
		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0,2), Input.get_joy_axis(0,3))
		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0,0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))
			camera_roate(joypad_vec.x * JOYPAD_SENSITIVITY,-joypad_vec.y * JOYPAD_SENSITIVITY)


func rotatePlayerToCamera(delta):
	#var cam_z = - $camera_base/camera_rot/Camera.global_transform.basis.z
	var cam_z = - get_node("../camera_base/camera_rot/Camera").global_transform.basis.z
	#var cam_x = $camera_base/camera_rot/Camera.global_transform.basis.x
	var cam_x = get_node("../camera_base/camera_rot/Camera").global_transform.basis.x
	
	cam_z.y=0
	cam_z = cam_z.normalized()
	cam_x.y=0
	cam_x = cam_x.normalized()

	# convert orientation to quaternions for interpolating rotation
	var target = cam_z * motion.y - cam_x * motion.x
	if (target.length() > 0.001):
		var q_from = get_core_frame_rotation()
		var q_to = Quat(Transform().looking_at(target,Vector3(0,1,0)).basis)
		if not spin:	# interpolate current rotation with desired one
			set_core_frame_rotation(q_from.slerp(q_to,delta*ROTATION_INTERPOLATE_SPEED))

func setForwardDirection(boost_area_forward_direction, entry, exit):
	boost_zone_forward = boost_area_forward_direction
	print(boost_zone_forward)
	boost_zone_entry = entry
	boost_zone_exit = exit
	
func boost_zone(delta):
	var boost_zone_velocity = get_core_frame_velocity()
	if boost_zone_entry:
		boost_zone_velocity = boost_zone_forward * boost_zone_speed
		move_core_frame(boost_zone_velocity,delta)
		
func self_rotate(delta):
	var a = get_core_frame_rotation()
	var b = Quat(Basis(get_core_frame_rotation()) * Basis(Vector3(0,1,0), PI * 1.5))
	set_core_frame_rotation(a.slerp(b,delta * SELF_ROTATE_SPEED ))
	
	
	
#Change character's velocity in boost zone
#func boost_zone(delta,boost_zone_forward):
	#var boost_zone_object = get_node("/root/BoostAreaVariables")
	#var boost_zone_forward
	#var boost_zone_velocity = get_core_frame_velocity()
	#boost_zone = boost_zone_object.entry
	#if boost_zone:
		#Get the boost_zone forward dirction and make the character face to that direction
		#boost_zone_forward = boost_zone_object.boost_zone_transform_basis_z
		#set_core_frame_rotation(boost_zone_object.transform.basis)
		#Set specific run boost direction
		#boost_zone_velocity = boost_zone_forward * boost_zone_speed
		#print(boost_zone_velocity)
		#move_core_frame(boost_zone_velocity,delta)
		#pass
		#boost_zone_transform = get_parent().get_node("BoostZone").gloabl_transform.basis
		#print(boost_zone_transform)


