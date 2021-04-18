extends Character

const BULLET_SCENE = preload("res://Objects/Bullet.tscn")

export var stomp_impulse = 1000.0

var can_continue_fire = false
var total_shots = 10
var shots_left = 10
var gunboots_duration = 0
var invincibility_duration = 0
var is_invincible = false
var curr_health = 4
var total_health = 4
var audio_player = AudioStreamPlayer.new()
var empty_sound_not_played = true
onready var invincibility_animation = $InvincibilityAnimation
onready var death_audio = $DeathAudio

func _ready():
	# Set bullet count text in GUI
	get_node("CanvasLayer/Interface").get_child(1).get_child(0).text = str(shots_left) + "/" + str(total_shots) 
	# Add AudioStreamPlayer to player
	self.add_child(audio_player)

# Kill enemy and reload gunboots when player stomps on head
func _on_StompZone_area_entered(area):
	velocity = calculate_stomp_velocity(velocity, stomp_impulse)
	shots_left = total_shots
	# Update bullet count text in GUI
	get_node("CanvasLayer/Interface").get_child(1).get_child(0).text = str(shots_left) + "/" + str(total_shots) 

# Lower player health when enemy collides with them, kill player when health is 0
func _on_EnemyDetector_body_entered(_body):
	if is_invincible: # Prevents player from taking damage while invincible
		return
	is_invincible = true
	invincibility_animation.play("StartBlink")
	curr_health -= 1
	var health_node = get_node("CanvasLayer/Interface").get_child(0)
	if curr_health > 0:
		audio_player.stream = load("res://Sounds/player_hit.wav")
		audio_player.play()
	# Update health text and health bar in GUI
	health_node.get_child(0).get_child(0).text = str(curr_health) + "/" + str(total_health) 
	health_node.get_child(1).value = curr_health 
	if curr_health == 0:
		death_audio.play()
		# Don't pause until the sound effect plays
		yield(death_audio, "finished") 
		# Prevent user from bring up pause menu while in game over
		get_node("CanvasLayer/Pause").set_process_input(false)
		get_tree().paused = true
		get_node("CanvasLayer/GameOver").get_child(1).get_child(0).get_child(0).get_child(0).text = 'You lose!'
		get_node("CanvasLayer/GameOver").visible = true

# Add player movement and physics
func _physics_process(delta: float):
	# One bullet fired when gun button pressed once in air
	if Input.is_action_just_pressed("jump_and_shoot") and not is_on_floor() and shots_left > 0:
		shots_left -= 1
		 # Update bullet count text in GUI
		get_node("CanvasLayer/Interface").get_child(1).get_child(0).text = str(shots_left) + "/" + str(total_shots)
		velocity.y = -250
		can_continue_fire = true # Player is not mid-jump, can continue firing if player keeps button held down
		shoot_bullet()
	# Play 'gun empty' noise when out of ammo and player tries to shoot
	elif Input.is_action_just_pressed("jump_and_shoot") and not is_on_floor() and shots_left <= 0:
		audio_player.stream = load("res://Sounds/trigger_click.wav")
		audio_player.play()
	
	# Bullets fired continuously when gun button held down
	if Input.is_action_pressed("jump_and_shoot") and not is_on_floor() and shots_left > 0 and can_continue_fire:
		gunboots_duration += delta
		if gunboots_duration >= 0.15:
			shots_left -= 1
			# Update bullet count text in GUI
			get_node("CanvasLayer/Interface").get_child(1).get_child(0).text = str(shots_left) + "/" + str(total_shots) 
			velocity.y = -250
			gunboots_duration = 0
			shoot_bullet()
	# Play 'gun empty' sound once when clip is empty and shoot button is still held down
	elif Input.is_action_pressed("jump_and_shoot") and not is_on_floor() and shots_left <= 0 and empty_sound_not_played:
		gunboots_duration += delta
		if gunboots_duration >= 0.15:	
			audio_player.stream = load("res://Sounds/trigger_click.wav")
			audio_player.play()
			empty_sound_not_played = false
			gunboots_duration = 0
		
	if Input.is_action_just_released("jump_and_shoot"):
		gunboots_duration = 0
		can_continue_fire = false
		
	# Reload gunboots when on floor
	if is_on_floor():
		# Player has reached the end and won the game
		if self.position.y > 14368:
			get_tree().paused = true
			get_node("CanvasLayer/Pause").set_process_input(false)
			get_node("CanvasLayer/GameOver").get_child(1).get_child(0).get_child(0).get_child(0).text = 'You win!'
			get_node("CanvasLayer/GameOver").visible = true
		if (shots_left < total_shots): # Only play reload sound when 1+ bullets in clip used
			audio_player.stream = load("res://Sounds/reload.wav")
			audio_player.play()
		shots_left = total_shots
		empty_sound_not_played = true
		# Update bullet count text in GUI
		get_node("CanvasLayer/Interface").get_child(1).get_child(0).text = str(shots_left) + "/" + str(total_shots)
		
	if is_invincible:
		invincibility_duration += delta
		if invincibility_duration >= 2: # Invincibility only lasts 2 seconds
			is_invincible = false
			invincibility_duration = 0
			invincibility_animation.play("StopBlink")
	
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
	audio_player.stream = load("res://Sounds/gunshot.wav")
	audio_player.play()
