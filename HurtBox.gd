extends Area2D

export(int) var duration = .7
var invincible = false setget set_invincible

onready var timer = $Timer
onready var coll2d = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
		
func _on_Timer_timeout():
	self.invincible = false

func _on_HurtBox_invincibility_started():
	coll2d.set_deferred("disabled", true)

func _on_HurtBox_invincibility_ended():
	coll2d.disabled = false

func _on_Enemy_start_invincibility():
	self.invincible = true
	timer.start(duration)
