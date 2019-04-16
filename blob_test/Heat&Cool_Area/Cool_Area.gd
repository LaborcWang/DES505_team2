extends Spatial

var show_state
var show_time
var show_timer

func _ready():
	$Trigger.connect("area_entered", self, "trigger_area_entered")
	show_state = true
	show_time = 3.0
	show_timer = 0

func _physics_process(delta):
	show_timer += delta
	if show_timer >= show_time:
		change_state()
		show_timer = 0
	pass

func trigger_area_entered(area):
	#If player enter
	if area.has_method("add_score"):
		get_node("../..").cool()

func change_state():
	if show_state:
		show_state = false
		$MeshInstance.visible = false
		$Trigger/CollisionShape.disabled = true
	else:
		show_state = true
		$MeshInstance.visible = true
		$Trigger/CollisionShape.disabled = false