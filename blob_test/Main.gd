extends Spatial

const DEFAULT_CLUSTER_STIFFNESS = 0.4
const MELTING_CLUSTER_STIFFNESS = 0.035
onready var cluster_stiffness = DEFAULT_CLUSTER_STIFFNESS
onready var target_cluster_stifness = DEFAULT_CLUSTER_STIFFNESS
const CLUSTER_STIFFNESS_INTERPOLATION_SPEED = 10.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if Input.is_action_pressed("melt"):
		$Player.core_enabled = false
		#$Player/Area/Core.scale.x = 0.5
		#$Player/Area/Core.scale.y = 0.5
		#$Player/Area/Core.scale.z = 0.5
		target_cluster_stifness = MELTING_CLUSTER_STIFFNESS
	else:
		$Player.core_enabled = true
		#$Player/Area/Core.scale.x = 1
		#$Player/Area/Core.scale.y = 1
		#$Player/Area/Core.scale.z = 1
		target_cluster_stifness = DEFAULT_CLUSTER_STIFFNESS
	
	cluster_stiffness = lerp(cluster_stiffness, target_cluster_stifness, delta*CLUSTER_STIFFNESS_INTERPOLATION_SPEED)
	
	$Player.set_group_cluster_stiffness("All", cluster_stiffness)

