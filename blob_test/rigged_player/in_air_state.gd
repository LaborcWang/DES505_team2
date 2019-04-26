extends "state.gd"

var player_controller
const AIR_TIME_MIN = 0.25
var min_air_time = 0

func _physics_process(delta):
	min_air_time -= delta
	player_controller = target
	var rigged_player : ParticleCharacter = target.get_parent()
	var animation_tree : AnimationTree = player_controller.get_parent().get_node("animation_tree")
	animation_tree.tree_root.get_node("State").xfade_time = 0.1
	animation_tree["parameters/State/current"] = 2 # jump
	rigged_player.get_node("face_anim/face_anim_tree")["parameters/State/current"] = 2 # in_aie
	
	# update orientation from root motion
	# hacked just now until I get a run anim
	var root_motion = Transform()

	player_controller.update_orientation(root_motion)
	var orientation = player_controller.get_orientation()
	var actor_displacement = orientation.origin
	
	player_controller.jump.tick(delta)
	
	# add a velocity for jumping so we can do a forward moving run jump
	actor_displacement = player_controller.jump_velocity*delta
	
	if player_controller.jump.is_in_freefall():
		actor_displacement.x = 0.0
		actor_displacement.z = 0.0
	
	actor_displacement.y = player_controller.jump.get_displacement(delta)
	
	var velocity = actor_displacement / delta
	velocity = player_controller.move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))
	
	if player_controller.grab_pole_cooldown > 0:
		player_controller.grab_pole_cooldown -= delta
	
	var hanging_test = false
	
	hanging_test = player_controller.grab_pole
	if hanging_test:
		hanging_test = hanging_test and player_controller.grab_pole_cooldown <= 0
	if hanging_test:
		hanging_test = hanging_test and player_controller.grab_pole_facing != 0
	
	if hanging_test:
		state_machine.transition("hanging")
	elif player_controller.has_ground_contact:
		if min_air_time <= 0:
			state_machine.transition("on_ground")
		
func _on_enter_state():
	target.has_ground_contact = false
	target.grab_pole_cooldown = 0
	min_air_time = AIR_TIME_MIN
	

	
	
