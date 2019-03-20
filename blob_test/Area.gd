extends Area

signal entry
signal exit

func _on_Area_area_entered(area):
	emit_signal("entry")
	pass # Replace with function body.


func _on_Area_area_exited(area):
	emit_signal("exit")
	pass # Replace with function body.
