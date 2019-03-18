extends Area

var minor_collectibles = 0
var UI_status_label
var coin_label
var timer
var addscore
#enum stamp_type {blue = 0, green = 0, yellow = 0, red = 0}
var global

func _ready():
	minor_collectibles = 0
	UI_status_label = $HUD/Panel/Label
	coin_label = $HUD/Collectables/Label
	global = get_node("/root/Globals")
	$HUD/coin_anim.visible = false
	timer = 0
	addscore = 0

func _physics_process(delta):
	process_UI(delta)
	if addscore != 0:
		timer += delta
		if timer >= 1.3:
			minor_collectibles += addscore
			addscore = 0
			timer = 0

func add_score(value):
	$HUD/coin_anim.visible = true
	get_node("../AnimationPlayer").play("coin_animation")
	addscore = value
	#minor_collectibles += value

func process_UI(delta):
	#UI_status_label.text = "Minor Collectibles:\n" + str(minor_collectibles)
	coin_label.text = str(minor_collectibles)

func collect_stamp(stamp_station_type):
	global.stamp_type[stamp_station_type] = 1