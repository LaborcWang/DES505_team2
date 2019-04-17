extends Area

var speed_in_water = 0.5
var speed_normal = 2

func _ready():
	connect("area_entered", self, "player_area_entered")
	connect("area_exited", self, "player_area_exited")
	
func player_area_entered(area):
	if area.has_method("add_score"):
		if get_node("../Player/Player").spin:
			get_node("../Player/Player").movement_speed = speed_normal
		else:
			get_node("../Player/Player").movement_speed = speed_in_water

func player_area_exited(area):
	if area.has_method("add_score"):
		get_node("../Player/Player").movement_speed = speed_normal

