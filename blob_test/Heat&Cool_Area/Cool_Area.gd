extends Spatial

func _ready():
	$Trigger.connect("area_entered", self, "trigger_area_entered")

func _physics_process(delta):
	#$MeshInstance.visible = false
	pass

func trigger_area_entered(area):
	#If player enter
	if area.has_method("add_score"):
		get_node("../..").cool()
