extends Node

var enemies_alive = 0

func _enter_tree():
	if PlayerStats.first_spawn:
		PlayerStats.reset_stats()
