extends Character

# Add player movement and physics
func _physics_process(delta: float):
	var is_jump_interrupted = Input.is_action_just_released("jump_and_shoot") and velocity.y < 0.0
	
	var direction = get_direction()
	
	if direction.x < 0:
		get_node("Sprite").flip_h = true
	elif direction.x > 0:
		get_node("Sprite").flip_h = false
	
	velocity = calculate_move_velocity(velocity, direction, speed, is_jump_interrupted)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)

# Return a Vector2 with the player's x and y direction 
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump_and_shoot") and is_on_floor() else 1.0
	)

# Return a Vector2 with the player's x and y velocity 
func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var new_v = linear_velocity
	new_v.x = speed.x * direction.x
	new_v.y += gravity * get_physics_process_delta_time()
	
	if direction.y == -1.0:
		new_v.y = speed.y * direction.y
		
	if is_jump_interrupted:
		new_v.y = 0.0
		
	return new_v
