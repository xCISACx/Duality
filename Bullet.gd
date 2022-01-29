extends KinematicBody2D

export var speed = 300
var direction = Vector2.ZERO

func _physics_process(delta):
	
	move_and_collide(direction.normalized() * delta * speed)
	# :3


func _on_HitBox_area_entered(area):
	queue_free()
