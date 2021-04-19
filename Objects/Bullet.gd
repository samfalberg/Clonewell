extends KinematicBody2D

const BULLET_SPEED = 2500

func _physics_process(delta: float):
	var motion = Vector2(0, 1) * BULLET_SPEED
	position += motion * delta
	var collision = move_and_collide(motion * delta)
	
	if collision and collision.collider is TileMap:
		var tile_pos = collision.collider.world_to_map(position)
		tile_pos -= collision.normal
		var tile_id = collision.collider.get_cellv(tile_pos)
		
		# Add cracks to breakable blocks or destroy cracked blocks
		if tile_id == 3:
			collision.collider.set_cellv(tile_pos, 8)
		elif tile_id == 8:
			collision.collider.set_cellv(tile_pos, -1)
			
		# Destroy bullet
		queue_free() 
		
# Destroy bullet when it touches enemy
func _on_BulletArea_area_entered(area):
	queue_free()

# Remove bullet when it goes off screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
