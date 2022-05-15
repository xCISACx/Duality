extends Node

var enemies_alive = 0
var cleared_floors = 0
var total_enemies_slain = 0
var portal_spawned = false
onready var player = null
onready var portal = null

func _enter_tree():
	if PlayerStats.first_spawn:
		PlayerStats.reset_stats()
