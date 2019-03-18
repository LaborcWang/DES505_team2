extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	# use this function to change the which particle group
	# is used as the core
	#$Player.set_core_group("Head")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#disable the core so all particles are free to move around
	$Player.core_enabled = false
	
	# set all the particles in the group to pull the head up
	$Player.set_group_velocity("Head", Vector3(0, 2.0, 0))
	pass

