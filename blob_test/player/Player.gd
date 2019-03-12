extends ParticleCharacter

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var movement_speed = 2
var motion = Vector2()
const ROTATION_INTERPOLATE_SPEED = 10
const MOTION_INTERPOLATE_SPEED = 10
const CAMERA_INTERPOLATE_SPEED = 10
const GROUND_RAY_LENGTH = 0.6
const JUMP_SPEED = 15
const CAMERA_ROTATION_SPEED = 0.01
const CAMERA_X_ROT_MIN = -20
const CAMERA_X_ROT_MAX = 45
var is_grounded = false
var jump_started = false
var camera_lookat : Vector3
var camera_x_rot = 0.00




# Called when the node enters the scene tree for the first time.
func _ready():
	camera_lookat = get_core_frame_position()
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if event is InputEventMouseMotion:
		$camera_base.rotate_y( event.relative.x * CAMERA_ROTATION_SPEED )
		$camera_base.orthonormalize() # after relative transforms, camera needs to be renormalized
		camera_x_rot = clamp(camera_x_rot + event.relative.y * CAMERA_ROTATION_SPEED,deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX) )
		$camera_base/camera_rot.rotation.x =  camera_x_rot

func _physics_process(delta):
	# called before the simulation is run
	
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
	


func _commands_process(commands):
	#if get_tree().paused == true:
	#	movement_speed = 0
	#	return
	# called after the simulation is run
	var delta = get_physics_process_delta_time()
	var move_velocity : Vector3

	move_velocity = get_core_frame_velocity();

	# set the xz in the velocity for player movement
	# leave y so gravity affects the body
	move_velocity.x = motion.x*movement_speed
	move_velocity.z = motion.y*movement_speed
	
	# change the y velocity to make that player jump
	if jump_started:
		move_velocity.y = JUMP_SPEED
	
	#rotate the character relative to the camera
	rotatePlayerToCamera(delta)
	move_velocity = $camera_base.global_transform.basis.xform(move_velocity)
	# set the desired velocity of the core
	move_core_frame(move_velocity, delta)	
	
	# this makes the camera follow the player
	camera_lookat = camera_lookat.linear_interpolate( get_core_frame_position(), CAMERA_INTERPOLATE_SPEED * delta)
	$camera_base.global_transform.origin = camera_lookat

	
func rotatePlayerToCamera(delta):
	var cam_z = - $camera_base/camera_rot/Camera.global_transform.basis.z
	var cam_x = $camera_base/camera_rot/Camera.global_transform.basis.x
	
	cam_z.y=0
	cam_z = cam_z.normalized()
	cam_x.y=0
	cam_x = cam_x.normalized()

	# convert orientation to quaternions for interpolating rotation
	var target = cam_z * motion.y - cam_x * motion.x
	if (target.length() > 0.001):
		var q_from = get_core_frame_rotation()
		var q_to = Quat(Transform().looking_at(target,Vector3(0,1,0)).basis)

		# interpolate current rotation with desired one
		set_core_frame_rotation(q_from.slerp(q_to,delta*ROTATION_INTERPOLATE_SPEED))
		