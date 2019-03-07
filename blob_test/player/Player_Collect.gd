extends Area

var minor_collectibles = 0
var UI_status_label
#enum stamp_type {blue = 0, green = 0, yellow = 0, red = 0}
var global

func _ready():
	minor_collectibles = 0
	UI_status_label = $HUD/Panel/Label
	global = get_node("/root/Globals")

func _physics_process(delta):
	process_UI(delta)

func add_score(value):
	minor_collectibles += value

func process_UI(delta):
	UI_status_label.text = "Minor Collectibles:\n" + str(minor_collectibles)

func collect_stamp(stamp_station_type):
	global.stamp_type[stamp_station_type] = 1