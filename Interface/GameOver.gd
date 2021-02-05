extends Control

#Start over game on try again button press
func _on_AgainButton_pressed():
	get_tree().reload_current_scene()

#Exit game on quit button press
func _on_QuitButton_pressed():
	get_tree().quit()
