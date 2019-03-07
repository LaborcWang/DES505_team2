extends Spatial

const RESPAWN_TIME = 3
var respawn_timer = 0
var coin_value = 1
var audio_coin = preload("res://Coin/coin2.wav")
var audio_node = null
var rs # rotate speed

var globals

func _ready():
	$Trigger.connect("area_entered", self, "trigger_area_entered")
	audio_node = $AudioStreamPlayer3D
	audio_node.stop()
	show_model(true)
	rs = 0.02
	globals = get_node("/root/Globals")
	global_transform.origin = globals.get_respawn_position()

func _physics_process(delta):
	rotate_y(rs)
	process_respawn(delta)

func process_respawn(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			global_transform.origin = globals.get_respawn_position()
			show_model(true)

func show_model(enable):
	$Holder.visible = enable
	$Trigger/CoinCollision.disabled = !enable

func trigger_area_entered(area):
	#rs = 0
	if area.has_method("add_score"):
		area.add_score(coin_value)
		respawn_timer = RESPAWN_TIME
		audio_node.play()
		show_model(false)