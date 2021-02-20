extends Character

var timer = 0.0
var direction = "Left"
var health = 3
var player_near = false
onready var damaged_animation = $DamagedAnimation
	
func _on_HitDetector_area_shape_entered(area_id, area, area_shape, self_shape):
	# Find name of the node that entered cat
	var collision_name = area.shape_owner_get_owner(shape_find_owner(area_shape))
	var area_name = collision_name.get_parent().get_name()
	# If node is bullet, lower health by 1
	if area_name == 'Bullet':
		health -= 1
		if health == 0:
			get_node("CollisionShape2D").disabled = true
			queue_free()
		damaged_animation.play("Damaged")
	# Kill enemy immediately when stomped on head
	elif area_name == 'StompZone':
		get_node("CollisionShape2D").disabled = true
		queue_free()
	
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
