extends Control

onready var floorCountLabel = $UI/VBoxContainer2/FloorsClearedAmount
onready var enemiesSlainLabel = $UI/VBoxContainer2/EnemiesSlainAmount
onready var player

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if !player:
		if GameManager.player:
			GameManager.player.connect("player_dead", self, "show")
	
func show():
	self.floorCountLabel.text = String(GameManager.cleared_floors)
	self.enemiesSlainLabel.text = String(GameManager.total_enemies_slain)
	$UI.show()
	
func _on_Quit_ToMenuButton_pressed():
	get_tree().change_scene_to(load('res://MainMenu.tscn'))

func _on_RestartGameButton_pressed():
	PlayerStats.reset_stats()
	get_tree().reload_current_scene()
