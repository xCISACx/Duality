extends Node

export(int) var max_health = 2
onready var health = max_health setget set_health

signal no_health
signal enemy_amount_changed
signal all_enemies_dead

func set_health(value):
	#print(health)
	health = value
	if health <= 0:
		emit_signal("no_health")

func set_enemy_amount(value):
	GameManager.enemies_alive = value
	emit_signal("enemy_amount_changed", GameManager.enemies_alive)
	if GameManager.enemies_alive <= 0:
		emit_signal("all_enemies_dead")
