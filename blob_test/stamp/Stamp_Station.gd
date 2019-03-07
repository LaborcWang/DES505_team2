extends Spatial

var audio_node = null
export (String) var stamp_station_type

var globals

func _ready():
	$Trigger.connect("area_entered", self, "trigger_area_entered")
	$Near_Area.connect("area_entered", self, "near_stamp_station")
	$Near_Area.connect("area_exited", self, "leave_stamp_station")
	audio_node = $AudioStreamPlayer3D
	audio_node.stop()
	show_model(true)
	globals = get_node("/root/Globals")
	$Subtitle.hide()

func _physics_process(delta):
	pass

func near_stamp_station(area):
	if area.has_method("collect_stamp"):
		$Subtitle.show()

func leave_stamp_station(area):
	if area.has_method("collect_stamp"):
		$Subtitle.hide()

func show_model(enable):
	$Holder.visible = enable
	$Trigger/CollisionShape.disabled = !enable
	$Near_Area/CollisionShape.disabled = !enable

func trigger_area_entered(area):
	if area.has_method("collect_stamp"):
		area.collect_stamp(stamp_station_type)
		audio_node.play()
		show_model(false)
		$Subtitle.hide()

