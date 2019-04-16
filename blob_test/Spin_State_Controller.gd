extends Spatial


func _ready():
	pass

func _physics_process(delta):
	if !get_node("Player").spin:
		$Camera.transform = $Player/camera_base/camera_rot/Camera.transform
		if Input.is_action_just_pressed("spin"):
			$Camera.make_current()
			$Player/camera_base/camera_rot/Camera.clear_current()
			get_node("Player").spin = true
	else:
		
		pass