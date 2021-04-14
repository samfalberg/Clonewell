extends Character

var timer = 0.0
var direction = "Left"
var health = 3
var player_near = false
var audio_player = AudioStreamPlayer.new()
onready var damaged_animation = $DamagedAnimation
onready var death_audio = $DeathAudio

func _ready(): 
	# Add AudioStreamPlayer to player
	self.add_child(audio_player)
	
func _on_HitDetector_area_shape_entered(area_id, area, area_shape, self_shape):
	# Find name of the node that entered cat
	var collision_name = area.shape_owner_get_owner(shape_find_owner(area_shape))
	var area_name = collision_name.get_parent().get_name()
	# If node is bullet, lower health by 1
	if area_name == 'Bullet':
		health -= 1
		audio_player.stream = load("res://Sounds/enemy_hit.wav")
		audio_player.play()
		damaged_animation.play("Damaged")
		if health == 0:
			kill_enemy()
			death_audio.play()
	# Kill enemy immediately when stomped on head
	elif area_name == 'StompZone':
		damaged_animation.play("Damaged")
		kill_enemy()
		
	
# Make cat pounce when player is near	
func _on_PlayerNearDetector_body_entered(body):
	timer = 0.0
	player_near = true
	
# Stop cat from pouncing when player not near
func _on_PlayerNearDetector_body_exited(body):
	player_near = false

func _physics_process(delta: float):
	timer += delta
	velocity.y += gravity * delta
	
	# Stop cat from sliding when it lands
	if is_on_floor():
		velocity.x = 0.0
	
	# Make cat enemy jump every 3.5 seconds when player near, jump the direction they're facing
	if timer >= 3.5 and player_near:
		velocity.x = 300.0 * (-1.0 if direction == "Left" else 1.0)
		velocity.y = -2000.0
		timer = 0.0
	
	# Turn enemy around if colliding with wall
	if is_on_wall():
		change_direction()
		
	velocity = move_and_slide(velocity, FLOOR_NORMAL)	

func change_direction():
	if direction == "Left":
		get_node("Sprite").set_flip_h(true)
		get_node("CollisionShape2D").position.x *= -1
		get_node("HitDetector/KillShape2D").position.x *= -1
		direction = "Right"
	elif direction == "Right":
		get_node("Sprite").set_flip_h(false)
		get_node("CollisionShape2D").position.x *= -1
		get_node("HitDetector/KillShape2D").position.x *= -1
		direction = "Left"
		
func kill_enemy():
	death_audio.play()
	yield (death_audio, "finished") # Don't queue_free() until the sound effect plays
	get_node("CollisionShape2D").disabled = true
	queue_free()
