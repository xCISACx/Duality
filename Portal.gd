extends StaticBody2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		PlayerStats.first_spawn = false
		GameManager.cleared_floors = GameManager.cleared_floors + 1
		get_tree().reload_current_scene()
