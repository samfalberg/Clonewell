extends Character

const BULLET_SCENE = preload("res://Objects/Bullet.tscn")

export var stomp_impulse = 1000.0

var on_ground = false
var shots_left = 10
var gunboots_duration = 0
var health = 4

# Kill enemy and realod gunboots when player stomps on head
func _on_EnemyDetector_area_entered(_area):
	velocity = calculate_stomp_velocity(velocity, stomp_impulse)
	shots_left = 10
	
# Lower player health when enemy collides with them, kill player when health is 0
func _on_EnemyDetector_body_entered(_body):
	health -= 1
	if health == 0:
		queue_free()
	print(health)

# Add player movement and physics
func _physics_process(delta: float):
	# One bullet fired when gun button pressed once in air
	if Input.is_action_just_pressed("jump_and_shoot") and not is_on_floor() and shots_left > 0:
		shots_left -= 1
		velocity.y = -500
		shoot_bullet()
	
	# Bullets fired continuously when gun button held down
	if Input.is_action_pressed("jump_and_shoot") and not is_on_floor() and shots_left > 0:
		gunboots_duration += delta
		if gunboots_duration >= 0.15:
			shots_left -= 1
			velocity.y = -250
			gunboots_duration = 0
			shoot_bullet()
		
	if Input.is_action_just_released("jump_and_shoot"):
		shots_left = 10
		gunboots_duration = 0
	
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
		-1.0 if Input.is_action_just_pressed("jump_and_shoot") and is_on_floor() else 0.0
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

# Cause an upward stomp impulse when player stomps on enemy heads
func calculate_stomp_velocity(linear_velocity: Vector2, impulse: float) -> Vector2:
	var out = linear_velocity
	out.y = -impulse
	return out
	
func shoot_bullet():
	var bullet = BULLET_SCENE.instance()
	get_parent().add_child(bullet)
	bullet.position = get_node("Position2D").global_position
