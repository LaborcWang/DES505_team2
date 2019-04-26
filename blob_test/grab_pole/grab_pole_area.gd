extends Area

const GRAB_COOLDOWN_TIME = 0.5
var grab_cooldown = 0

func _physics_process(delta):
	if(grab_cooldown > 0):
		grab_cooldown -= delta

func _on_grab_pole_area_body_entered(body):
	var main : Spatial = get_tree().get_root().get_node("main")
	var player = body.get_parent()
	
	if body.name == "player_controller" and not player.swing_active and grab_cooldown <= 0:
		#print(self.name+" grab: "+String(grab_cooldown))
		body.set_grab_pole(self.get_parent())

func _on_grab_pole_area_body_exited(body):
	if body.name == "player_controller":
		var player = body.get_parent()
		body.set_grab_pole(null)
			
func start_cooldown():
	grab_cooldown = GRAB_COOLDOWN_TIME

