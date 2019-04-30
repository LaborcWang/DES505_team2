extends "state.gd"

const SWING_ACCELERATION = 200.0
const SWING_DISTANCE_MAX = 1.1
const GLOBAL_DEFAULT_STIFFNESS = 0.4
const CONTROLLER_LEG_OFFSET_Y = -0.1
const GRAB_POLE_COOLDOWN = 0.5


var attached = true
var detach = false
var attach = true

var player_controller
var rigged_player : ParticleCharacter

var arm_left_group
var arm_right_group

var grab_pole : Spatial

func _physics_process(delta):
	player_controller = target
	rigged_player = player_controller.get_parent()
	
	player_controller.jump.tick(delta)
	
	var animation_tree : AnimationTree = player_controller.get_parent().get_node("animation_tree")
	animation_tree.tree_root.get_node("State").xfade_time = 0.1
	animation_tree["parameters/State/current"] = 2 # jump
	
	# update orientation from root motion
	# hacked just now until I get a run anim
	var root_motion = Transform()

	player_controller.update_orientation(root_motion)
	var orientation = player_controller.get_orientation()
	var actor_displacement = orientation.origin
	
	if attach:
		#print("attach")
		attach = false
		grab_pole = player_controller.grab_pole
		player_controller.grab_pole  = null
		if grab_pole:
			attached = true
			setup_anim_blends()
			setup_up_stiffness()
			rigged_player.set_group_mass("hand_left", 0)
			rigged_player.set_group_mass("hand_right", 0)
		
	if detach:
		detach = false
		attached = false
		restore_anim_blends()
		restore_stiffness()
		rigged_player.set_group_mass("hand_left", -1)
		rigged_player.set_group_mass("hand_right", -1)
		rigged_player.swing_active = false
		grab_pole.get_node("grab_pole_area").start_cooldown()
		#print("detach")
	
	if attached and grab_pole:
		var hand_left_transform = Transform(Basis(Vector3(0, 1, 0), deg2rad(180)), Vector3(0, 0, -0.4))
		var hand_right_transform = Transform(Basis(Vector3(0, 1, 0), deg2rad(0)), Vector3(0, 0, 0.4))
		
		if player_controller.grab_pole_facing < 0:
			hand_left_transform = Transform(Basis(Vector3(0, 1, 0), deg2rad(180))) * hand_left_transform
			hand_right_transform = Transform(Basis(Vector3(0, 1, 0), deg2rad(180))) * hand_right_transform
		
		hand_left_transform = grab_pole.global_transform * hand_left_transform
		hand_right_transform = grab_pole.global_transform * hand_right_transform
		
		rigged_player.transform_group("hand_left", hand_left_transform)
		rigged_player.transform_group("hand_right", hand_right_transform)

		update_controller_position()
		rigged_player.swing_active = true
		swing(delta)
		if Input.is_action_just_pressed("jump"):
			detach = true
		

		
		
	if not attached:
		player_controller.jump.reset()
		player_controller.jump_velocity = rigged_player.swing_velocity
		state_machine.transition("in_air")


func _on_enter_state():
	player_controller = target
	rigged_player = player_controller.get_parent()
	arm_left_group = rigged_player.find_group("arm_left")
	arm_right_group = rigged_player.find_group("arm_right")
	detach = false
	attach = true
	
func _on_exit_state():
	player_controller.grab_pole_cooldown = GRAB_POLE_COOLDOWN
	
func setup_anim_blends():
	rigged_player.set_group_anim_blend(-1, 0)
	rigged_player.apply_group(-1)

func setup_up_stiffness():
		rigged_player.set_group_cluster_stiffness("Global", 0.3)
		rigged_player.set_group_cluster_stiffness("arm_left", 0.1)
		rigged_player.set_group_cluster_stiffness("arm_right", 0.1)
		
func restore_anim_blends():
	rigged_player.set_group_anim_blend(-1, 1)
	rigged_player.apply_group(-1)
	for group_num in range(rigged_player.group_count):
		rigged_player.apply_group(group_num)
		
func restore_stiffness():
		rigged_player.set_group_cluster_stiffness("Global", GLOBAL_DEFAULT_STIFFNESS)
		for group_num in range(rigged_player.group_count):
			var group_property_name = "group_"+String(group_num)
			var group_name = rigged_player.get_group_name(group_num)
			var group_stiffness = rigged_player.get_group_default_cluster_stiffness(group_num)
			if group_stiffness >= 0:
				rigged_player.set_group_cluster_stiffness(group_name, group_stiffness)
			
func swing(delta):	#swing acceleration is calculated based on the stretched length of the character
	var swing_acc = SWING_ACCELERATION
	
	var grab_pole_position = grab_pole.global_transform.origin
	var swing_direction = Vector3(1, 0, 1) * grab_pole.transform.basis.x
	
	
	var player_body_position : Vector3 = rigged_player.get_node("particle_groups/inner_body_area").global_transform.origin
	var player_swing_direction : Vector3 = player_body_position - grab_pole_position
	player_swing_direction.y = 0
	
	var projected_swing_distance = player_swing_direction.dot(swing_direction)
	
	#print("x: "+String(player_body_position.x)+" "+String(projected_swing_distance))
	

	#var horizontal_input_axis = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var swing_input = Vector3()
	swing_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	swing_input.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	swing_input.y = 0
	
	if abs(projected_swing_distance) < SWING_DISTANCE_MAX:
		#rigged_player.swing_acceleration = swing_direction*horizontal_input_axis*swing_acc
		rigged_player.swing_acceleration = swing_direction*swing_direction.dot(swing_input)*swing_acc
	else:
		rigged_player.swing_acceleration = Vector3()
		
func update_controller_position():
	var leg_left : Area = rigged_player.get_node("particle_groups/leg_left_area")
	var leg_right : Area = rigged_player.get_node("particle_groups/leg_right_area")
	
	var leg_left_pos = leg_left.global_transform.origin
	var leg_right_pos = leg_right.global_transform.origin
	
	var controller_pos = (leg_left_pos + leg_right_pos)*0.5
	controller_pos.y += CONTROLLER_LEG_OFFSET_Y
	
	player_controller.global_transform.origin = controller_pos
