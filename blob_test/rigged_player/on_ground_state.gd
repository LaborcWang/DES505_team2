extends "state.gd"

const PLAYER_MOVEMENT_SPEED = 1.5
const RUN_JUMP_SPEED = 3.0
const JUMP_SPEED = 4

func _physics_process(delta):
	var player_controller = target
	var rigged_player : ParticleCharacter = target.get_parent()
	var animation_tree : AnimationTree = player_controller.get_parent().get_node("animation_tree")
	
	var input_length = player_controller.motion_input.length()
	
	player_controller.rotate_player_to_camera(delta)
	
	animation_tree.tree_root.get_node("State").xfade_time = 0.3
	if(input_length > 0.1):
		animation_tree["parameters/State/current"] = 1 # walk_run
		animation_tree["parameters/walk_run_blend/blend_position"] = input_length
		rigged_player.get_node("face_anim/face_anim_tree")["parameters/State/current"] = 1 # moving
	else:
		animation_tree["parameters/State/current"] = 0 # idle
		rigged_player.get_node("face_anim/face_anim_tree")["parameters/State/current"] = 0 # idle
		
	var	root_motion = animation_tree.get_root_motion_transform()
	player_controller.update_orientation(root_motion)
	var orientation = player_controller.get_orientation()
	
	var actor_displacement = orientation.origin

	player_controller.jump.tick(delta)
	var ground_basis = Basis(Vector3.RIGHT, deg2rad(-player_controller.ground_angle))
	actor_displacement = ground_basis.xform(actor_displacement)
	var velocity = actor_displacement / delta
	velocity = player_controller.move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))
		
	if !player_controller.has_ground_contact:
		state_machine.transition("in_air")
	elif Input.is_action_just_pressed("jump"):
		player_controller.jump.start_jump(JUMP_SPEED)
		state_machine.transition("in_air")
		#calculate jump velocity
		player_controller.jump_velocity = Vector3()
		#check anim state, if character is running then lets add a velocity onto the jump
		if animation_tree["parameters/State/current"] == 1: #walk_run
			player_controller.jump_velocity = orientation.basis.z
			player_controller.jump_velocity *= RUN_JUMP_SPEED
		
		
	else:
		target.jump.reset()
		
