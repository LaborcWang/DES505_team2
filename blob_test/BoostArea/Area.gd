extends Area

var boost_zone_transform_basis_z : Vector3
var entry: bool 
var exit: bool 

func _ready():
	entry = false
	exit = false

func _on_BoostArea_area_entered(area):
	if area.get_owner().name == "PlayerSceneRoot":
		entry = true
		exit = false
		boost_zone_transform_basis_z = get_parent().transform.basis.z
		#print(boost_zone_transform_basis_z)
		#print("aaaa","  ",entry)
		if area.has_method("add_score"):
			area.get_parent().setForwardDirection(boost_zone_transform_basis_z,entry,exit)
	pass # Replace with function body.

func _on_BoostArea_area_exited(area):
	if area.get_owner().name == "PlayerSceneRoot":
		exit = true
		entry = false
		boost_zone_transform_basis_z = Vector3(0,0,0)
		if area.has_method("add_score"):
			area.get_parent().setForwardDirection(boost_zone_transform_basis_z,entry,exit)
		#print("bbbbb","  ",entry)
		
	pass # Replace with function body.
