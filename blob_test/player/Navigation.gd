extends ParticleCharacter

var path = []
var path_ind = 0
const move_speed = 100
onready var nav = get_parent()
onready var target_position = get_parent().get_parent()
func _physics_process(delta):
	
	if path_ind < path.size():
		var move_vec = (path[path_ind] - global_transform.origin)
		if move_vec.length() < 0.1:
			path_ind += 1
		else:
			move_core_frame(move_vec * move_speed , delta)
	
	
func move_to(target_pos):
	path = nav.get_simple_path(get_core_frame_position(),target_pos)
	path_ind = 0

func _input(event):
	if event is InputEventMouseButton:
		move_to(target_position.get_translation())
			
		