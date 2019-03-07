extends Spatial

func _ready():
	var globals = get_node("/root/Globals")
	globals.coin_respawn_points = get_children()
