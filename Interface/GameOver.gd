extends Control

var current_selection = 0
onready var selector_one = $CenterContainer/VBoxContainer/AgainButton
onready var selector_two = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	selector_one.grab_focus()

func _process(delta):
	# Only execute this code when menu is present
	if self.visible:
		# Only two menu options so up and down follow same logic
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
			if current_selection == 0:
				current_selection += 1
				set_current_selection(current_selection)
			else:
				current_selection = 0
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

func handle_selection(current_selection):	
	match current_selection:
		0:
			_on_AgainButton_pressed()
		1:
			_on_QuitButton_pressed()

# Start over game on try again button press
func _on_AgainButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

# Exit game on quit button press
func _on_QuitButton_pressed():
	get_tree().quit()
