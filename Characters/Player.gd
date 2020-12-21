extends KinematicBody2D

var velocity = Vector2.ZERO

# Add player movement and physics
func _physics_process(delta):
	velocity.y += 9.81 # Adds gravity
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = 300
		get_node("Sprite").flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -300
		get_node("Sprite").flip_h = true
	else: 
		velocity.x = 0
	
	velocity = move_and_slide(velocity)
