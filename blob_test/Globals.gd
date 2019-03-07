extends Node
#project/project setting/autoload
var mouse_sensitivity = 0.08
var joypad_sensitivity = 2

var coin_respawn_points = null

var stamp_type = {"blue" : 0, "green" : 0, "yellow" : 0, "red" : 0}


func _ready():
	randomize()

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)
	coin_respawn_points = null

func get_respawn_position():
	if coin_respawn_points == null:
		return Vector3(-3, 1.5, 0)
	else:
		var respawn_point = rand_range(0, coin_respawn_points.size() - 1)
		return coin_respawn_points[respawn_point].global_transform.origin
