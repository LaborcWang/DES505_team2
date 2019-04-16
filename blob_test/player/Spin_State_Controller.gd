extends Spatial


func _ready():
	pass 

func _physics_process(delta):
	if !get_node("Player").spin:
		if Input.is_action_just_pressed("spin"):
			get_node("Player").spin = true