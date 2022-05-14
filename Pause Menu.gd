extends Control

onready var menu = $Menu
onready var paused = get_tree().paused
onready var open = false
signal unpaused

# Called when the node enters the scene tree for the first time.
func _ready():
	menu.hide()
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_released("pause"):
		if !get_tree().paused:
			pause()
		else:
			unpause()
		pass

func pause():
	get_tree().paused = true
	menu.show()
	
func unpause():
	get_tree().paused = false
	emit_signal("unpaused")
	menu.hide()
	
func _on_ReturnToGameButton_pressed():
	unpause()

func _on_Quit_ToMenuButton_pressed():
	unpause()
	get_tree().change_scene_to(load('res://MainMenu.tscn'))

func _on_RestartGameButton_pressed():
	unpause()
	PlayerStats.reset_stats()
	get_tree().reload_current_scene()
