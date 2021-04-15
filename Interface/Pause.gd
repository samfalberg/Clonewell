extends Control

var current_selection = 0
onready var selector_one = $CenterContainer/VBoxContainer/ResumeButton
onready var selector_two = $CenterContainer/VBoxContainer/RestartButton
onready var selector_three = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	selector_one.grab_focus()

func _process(delta):
	# Only execute this code when menu is present
	if self.visible:
		# Allows keyboard users to navigate pause menu
		if Input.is_action_just_pressed("ui_down"):
			if current_selection == 2:
				current_selection = 0
				set_current_selection(current_selection)
			else:
				current_selection += 1
				set_current_selection(current_selection)
		elif Input.is_action_just_pressed("ui_up"):
			if current_selection == 0:
				current_selection = 2
				set_current_selection(current_selection)
			else:
				current_selection -= 1
				set_current_selection(current_selection)
		elif Input.is_action_just_pressed("ui_accept"):
			handle_selection(current_selection)

# Set which menu option is highlighted
func set_current_selection(current_selection):
	match current_selection:
		0:
			selector_one.grab_focus()
		1:
			selector_two.grab_focus()
		2:
			selector_three.grab_focus()

func handle_selection(current_selection):	
	match current_selection:
		0:
			_on_ResumeButton_pressed()
		1:
			_on_RestartButton_pressed()
		2:
			_on_QuitButton_pressed()
#
func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state = not get_tree().paused 
		get_tree().paused = new_pause_state
		visible = new_pause_state # Menu is only visible when paused

# Unpause game on resume button press
func _on_ResumeButton_pressed():
	var new_pause_state = not get_tree().paused 
	get_tree().paused = new_pause_state
	visible = new_pause_state 

# Restart game on restart button press
func _on_RestartButton_pressed():
	var new_pause_state = not get_tree().paused
	get_tree().reload_current_scene()
	get_tree().paused = new_pause_state
	visible = new_pause_state 

# Exit game on quit button press
func _on_QuitButton_pressed():
	get_tree().quit()

