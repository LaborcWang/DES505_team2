extends Area


var trigger_off_material : SpatialMaterial
var trigger_on_material : SpatialMaterial
var trigger_mesh : MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	trigger_off_material = load("res://trigger_test/trigger_off.tres")
	trigger_on_material = load("res://trigger_test/trigger_on.tres")
	trigger_mesh = $MeshInstance

func _on_Trigger_area_entered(area):
	if area.get_owner().name == "Player":
		trigger_mesh.set_surface_material(0, trigger_on_material)

func _on_Trigger_area_exited(area):
	if area.get_owner().name == "Player":
		trigger_mesh.set_surface_material(0, trigger_off_material)	
