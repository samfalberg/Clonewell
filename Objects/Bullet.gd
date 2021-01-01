extends Node2D

const BULLET_SPEED = 2500

func _physics_process(delta: float):
	var motion = Vector2(0, 1) * BULLET_SPEED
	position += motion * delta

# Destroy bullets when they touch the world
func _on_Bullet_body_entered(_body):
	queue_free()

# Destroy bullets when they touch enemies
func _on_Bullet_area_entered(_area):
	queue_free()
