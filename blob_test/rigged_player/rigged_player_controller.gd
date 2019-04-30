extends KinematicBody

const StateMachineFactory = preload("../addons/godot-finite-state-machine/state_machine_factory.gd")
const OnGroundState = preload("on_ground_state.gd")
const InAirState = preload("in_air_state.gd")
const HangingState = preload("hanging_state.gd")
const PlayerJump = preload("rigged_player_jump.gd")

const MOTION_INPUT_INTERPOLATE_SPEED = 10
const CAMERA_ROTATION_INTERPOLATE_SPEED = 10
const FALL_GRAVITY = -9.8
const FALL_SPEED_MAX = -20

onready var orientation : Transform = Transform()
onready var motion_input : Vector2 = Vector2()
onready var ground_angle = 0
onready var has_ground_contact = false
onready var fall_speed  = 0
onready var jump = PlayerJump.new()
onready var grab_pole = null
onready var grab_pole_cooldown = 0
onready var grab_pole_plane = Plane()
onready var grab_pole_facing = 0

var jump_velocity = Vector3()

#state machine factory
onready var smf = StateMachineFactory.new()

#player state machine
var psm


func create_player_state_machine():
	psm = smf.create({
	"target": self,
	"current_state": "in_air",
	"states": [
		{"id": "on_ground", "state": OnGroundState},
		{"id": "in_air", "state": InAirState},
		{"id": "hanging", "state": HangingState},
	],
	"transitions": [
		{"state_id": "on_ground", "to_states": ["in_air"]},
		{"state_id": "in_air", "to_states": ["on_ground", "hanging"]},
		{"state_id": "hanging", "to_states": ["in_air"]},
	]
})

# Called when the node enters the scene tree for the first time.
func _ready():
	create_player_state_machine()

func get_orientation():
	return orientation
	
func set_orientation(var new_orientation):
	orientation = new_orientation
	
func update_orientation(var root_motion : Transform):
	orientation *= root_motion

func move_controller(delta):
	var input_length = motion_input.length()

	var root_motion = Transform(Basis(), Vector3(0, 0, input_length*1.5*delta))
	orientation *= root_motion
	var actor_displacement = orientation.origin	

	if !has_ground_contact:
		fall_speed = clamp(fall_speed+FALL_GRAVITY*delta, FALL_SPEED_MAX, 0)
		actor_displacement.y += fall_speed*delta
	else:
		var ground_basis = Basis(Vector3.RIGHT, deg2rad(-ground_angle))
		actor_displacement = ground_basis.xform(actor_displacement)
		fall_speed = 0

	# if actor is on the ground then rotate the displacement by ground angle
	var velocity = actor_displacement / delta
	velocity = move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))

func rotate_player_to_camera(delta):
	var cam_z = - $camera_base/camera_rot/camera.global_transform.basis.z
	var cam_x = $camera_base/camera_rot/camera.global_transform.basis.x
	
	cam_z.y=0
	cam_z = cam_z.normalized()
	cam_x.y=0
	cam_x = cam_x.normalized()

	# convert orientation to quaternions for interpolating rotation
	var target = cam_z * motion_input.y - cam_x * motion_input.x
	if (target.length() > 0.001):
		var q_from = Quat(orientation.basis)
		var q_to = Quat(Transform().looking_at(target,Vector3(0,1,0)).basis)

		# interpolate current rotation with desired one
		orientation.basis = Basis(q_from.slerp(q_to,delta*CAMERA_ROTATION_INTERPOLATE_SPEED))

func calculate_ground_contact():
	if is_on_floor():
		print("£££££££")
		has_ground_contact = true
	elif !$ground_ray.is_colliding():
		print("!!!!!!")
		has_ground_contact = false

func calculate_ground_angle():
	if($ground_ray.is_colliding()):
		var forward
		forward = orientation.basis.x.cross($ground_ray.get_collision_normal())
		ground_angle = 90 - rad2deg(acos(forward.dot(Vector3.UP)))
	else:
		ground_angle = 0

func _physics_process(delta):
	var target_motion_input = Vector2()
	target_motion_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	target_motion_input.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	motion_input = motion_input.linear_interpolate(target_motion_input, MOTION_INPUT_INTERPOLATE_SPEED * delta)
	
	calculate_ground_contact()
		# if player is detected as not on the floor
	# but the ground ray still says we're on the gound
	# then pull the player controller to the ground
	#if has_ground_contact and !is_on_floor():
	#	move_and_collide(Vector3(0, -1, 0))
	calculate_ground_angle()
	
	psm._physics_process(delta)
	#move_controller(delta)
	
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	$Armature.global_transform.basis = orientation.basis
	
func calculate_grab_pole_plane(var pole):
	grab_pole_plane.normal = pole.global_transform.basis.x
	grab_pole_plane.d = pole.global_transform.origin.dot(grab_pole_plane.normal)

func set_grab_pole(var pole):
	grab_pole = pole
	if grab_pole:
		calculate_grab_pole_plane(grab_pole)
		set_facing_grab_pole()

func set_facing_grab_pole():
	var player_direction = orientation.basis.z
	var facing = player_direction.dot(grab_pole_plane.normal)
	var plane_dist = grab_pole_plane.distance_to(global_transform.origin)
		
	grab_pole_facing = 0
	if(plane_dist < 0):
		# on the left
		if(facing > 0.9):
			grab_pole_facing = 1
	else:
		# on the right
		if(facing < -0.9):
			grab_pole_facing = -1

