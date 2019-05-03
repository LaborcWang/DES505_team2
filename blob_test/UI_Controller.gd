extends Node

var mouse_visible
var map_show
const MAP_SHOW_MIN_TIME = 0.5
var map_show_time
const MAP_CLOSE_MIN_TIME = 0.5
var map_close_time
var global
var global_listener_blue = 0
var global_listener_green = 0
var global_listener_yellow = 0
var global_listener_red = 0

#############Player_Collect
var minor_collectibles = 0
var collectables_label
var timer

#export (NodePath) var Player
#var player_collect


func _ready():
	mouse_visible = false
	$Pause/Map.hide()
	$Pause.hide()
	$Map2.hide()
	map_show = false
	map_show_time = 0
	map_close_time = 0
	$Pause/Background/Resume.connect("pressed", self, "resume")
	$Pause/Background/Quit.connect("pressed", self, "quit")
	$Pause/Background/Map.connect("pressed", self, "map")
	$Pause/Map/Map_Close.connect("pressed", self, "map_close")
	$Map2/Map2_Close.connect("pressed", self, "map2_close")
	global = get_node("/root/Globals")
	#player_collect = get_node(Player).get_node("/Area")
	###############
	minor_collectibles = 0
	collectables_label = $HUD/Collectables/Label
	$HUD/star_anim.visible = false
	timer = 0
	

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel") && !map_show:
		if mouse_visible:
			pass
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			#mouse_visible = false
			#get_tree().paused = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_visible = true
			get_tree().paused = true
			get_node("../PlayerSceneRoot/Player").movement_speed = 0
			$Pause.show()
			#$Pause/WindowDialog.popup(Rect2(420, 120, 200, 64))
	if Input.is_key_pressed(KEY_ENTER):
		if map_show && map_show_time > MAP_SHOW_MIN_TIME:
			map2_close()
		elif !map_show && map_close_time > MAP_CLOSE_MIN_TIME:
			map2_show()
	if map_show:
		map_show_time += delta
	else:
		map_close_time += delta
	
	stamp_process()
	listener_change_check()
	update_listener()
	add_score_UI(delta)

func add_score_UI(delta):
	if global.addscore != 0:
		if timer == 0:
			$HUD/star_anim.visible = true
			get_node("../AnimationPlayer").play("star_collect")
		timer += delta
		if timer >= 1.3:
			minor_collectibles += global.addscore
			global.addscore = 0
			timer = 0
	collectables_label.text = str(minor_collectibles)

func resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_visible = false
	get_tree().paused = false
	get_node("../Player/Player").movement_speed = 2
	$Pause.hide()

func quit():
	get_tree().quit()

func map():
	$Pause/Map.show()

func map_close():
	$Pause/Map.hide()

func map2_show():
	$Map2.show()
	map_show = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	get_node("../Player/Player").movement_speed = 0
	map_close_time = 0

func map2_close():
	$Map2.hide()
	$Map2/Label.visible = false
	map_show = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	get_node("../Player/Player").movement_speed = 2
	map_show_time = 0

func stamp_process():
	if global.stamp_type["blue"] == 1:
		$Map2/Blue_Stamp.visible = true
	if global.stamp_type["green"] == 1:
		$Map2/Green_Stamp.visible = true
	if global.stamp_type["yellow"] == 1:
		$Map2/Yellow_Stamp.visible = true
	if global.stamp_type["red"] == 1:
		$Map2/Red_Stamp.visible = true

func listener_change_check():
	if global_listener_blue != global.stamp_type["blue"]:
		map2_show()
		$Map2/Label.text = "“You got the Blue Stamp! Congratulations!”"
		$Map2/Label.visible = true
	if global_listener_green != global.stamp_type["green"]:
		map2_show()
		$Map2/Label.text = "“You got the Green Stamp! Congratulations!”"
		$Map2/Label.visible = true
	if global_listener_yellow != global.stamp_type["yellow"]:
		map2_show()
		$Map2/Label.text = "“You got the Yellow Stamp! Congratulations!”"
		$Map2/Label.visible = true
	if global_listener_red != global.stamp_type["red"]:
		map2_show()
		$Map2/Label.text = "“You got the Red Stamp! Congratulations!”"
		$Map2/Label.visible = true

func update_listener():
	global_listener_blue = global.stamp_type["blue"]
	global_listener_green = global.stamp_type["green"]
	global_listener_yellow = global.stamp_type["yellow"]
	global_listener_red = global.stamp_type["red"]

func _init():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)