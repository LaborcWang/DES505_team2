extends Spatial

const DEFAULT_CLUSTER_STIFFNESS = 0.4
const MELTING_CLUSTER_STIFFNESS = 0.035
onready var cluster_stiffness = DEFAULT_CLUSTER_STIFFNESS
onready var target_cluster_stifness = DEFAULT_CLUSTER_STIFFNESS
const CLUSTER_STIFFNESS_INTERPOLATION_SPEED = 10.0
var is_heat


# Called when the node enters the scene tree for the first time.
func _ready():
	is_heat = false

func _physics_process(delta):
	#print(is_heat)
	if (Input.is_action_pressed("melt") && not $PlayerSceneRoot/Player.jump_started) || is_heat:
		#$Player.core_enabled = false
		#$Player/Area/Core.scale.x = 0.5
		#$Player/Area/Core.scale.y = 0.5
		#$Player/Area/Core.scale.z = 0.5
		target_cluster_stifness = MELTING_CLUSTER_STIFFNESS
	else:
		#$Player.core_enabled = true
		#$Player/Area/Core.scale.x = 1
		#$Player/Area/Core.scale.y = 1
		#$Player/Area/Core.scale.z = 1
		target_cluster_stifness = DEFAULT_CLUSTER_STIFFNESS
	
	cluster_stiffness = lerp(cluster_stiffness, target_cluster_stifness, delta*CLUSTER_STIFFNESS_INTERPOLATION_SPEED)
	
	$PlayerSceneRoot/Player.set_group_cluster_stiffness("All", cluster_stiffness)
	

func heat():
	is_heat = true
	$PlayerSceneRoot/Player.melt = true
	#$Player.core_enabled = false

func cool():
	is_heat = false
	$PlayerSceneRoot/Player.melt = false
	#$Player.core_enabled = true
