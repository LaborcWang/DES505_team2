extends Spatial

var heat_time
var heat_timer
var stay
func _ready():
	$Trigger.connect("area_entered", self, "trigger_area_entered")
	$Trigger.connect("area_exited", self, "trigger_area_exited")
	heat_timer = 0
	heat_time = 3

func _physics_process(delta):
	#print(stay)
	if stay:
		heat_timer += delta
		if heat_timer >= heat_time:
			get_node("..").heat()

func trigger_area_entered(area):
	#If player enter
	if area.has_method("add_score"):
		stay = true

func trigger_area_exited(area):
	if area.has_method("add_score"):
		stay = false
		heat_timer = 0;
		#get_node("..").cool()