extends Spatial


func _ready():
	pass 

func _physics_process(delta):
	if !get_node("Player/Player").spin:
		update_camera()
		if Input.is_action_just_pressed("spin"):
			$camera_base/camera_rot/Camera.make_current()
			$Player/camera_base/camera_rot/Camera.clear_current()
			get_node("Player/Player").spin = true
	else:
		#movemet control and camera control here
		pass
		
func update_camera():
	$camera_base.transform = $Player/camera_base.transform
	$camera_base/camera_rot.transform = $Player/camera_base/camera_rot.transform
	$camera_base/camera_rot/Camera.transform = $Player/camera_base/camera_rot/Camera.transform