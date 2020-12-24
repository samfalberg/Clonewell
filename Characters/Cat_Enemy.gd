extends Character

var timer = 0.0
var direction = "Left"

func _physics_process(delta: float):
	timer += delta
	velocity.y += gravity * delta
	
	# Stop cat from sliding when it lands
	if is_on_floor():
		velocity.x = 0.0
	
	# Make cat enemy jump every 5 seconds, jump left if facing left, jump right if facing right
	if timer >= 5.0:
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
		direction = "Right"
	elif direction == "Right":
		get_node("Sprite").set_flip_h(false)
		direction = "Left"
