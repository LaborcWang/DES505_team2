extends Control

export (String, FILE) var main_scene
export (String, FILE) var spin_scene

func _ready():
	$Main_Page/Main_Level_Button.connect("pressed", self, "main_level_pressed")
	$Main_Page/Quit_Button.connect("pressed", self, "quit")
	$Main_Page/Spin_Level_Button.connect("pressed", self, "spin_level_pressed")

func quit():
	get_tree().quit()

func main_level_pressed():
	get_node("/root/Globals").load_new_scene(main_scene)

func spin_level_pressed():
	get_node("/root/Globals").load_new_scene(spin_scene)
