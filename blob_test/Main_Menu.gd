extends Control

export (String, FILE) var main_scene

func _ready():
	$Main_Page/Start_Button.connect("pressed", self, "start_pressed")
	$Main_Page/Quit_Button.connect("pressed", self, "quit")

func quit():
	get_tree().quit()

func start_pressed():
	get_node("/root/Globals").load_new_scene(main_scene)

