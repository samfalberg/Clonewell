extends MarginContainer

onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selector
onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selector

var current_selection = 0

func _ready():
	set_current_selection(0)
	
func _process(delta):
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

func handle_selection(current_selection):
	if current_selection == 0:
		get_tree().change_scene("res://World/Well.tscn")
	else:
		get_tree().quit()

# Set which menu option has the '>' symbol next to it
func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	
	if current_selection == 0:
		selector_one.text = ">"
	else:
		selector_two.text = ">"
