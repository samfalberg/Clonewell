extends Control

func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state = not get_tree().paused 
		get_tree().paused = new_pause_state
		visible = new_pause_state # Menu is only visible when paused
		
# Unpause game on resume button press
func _on_ResumeButton_pressed():
	var new_pause_state = not get_tree().paused 
	get_tree().paused = new_pause_state
	visible = new_pause_state # Menu is only visible when paused

#Exit game on quit button press
func _on_QuitButton_pressed():
	get_tree().quit()
