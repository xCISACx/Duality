extends Control

onready var startButton = $MainMenu/StartButton
onready var settingsButton = $MainMenu/SettingsButton
onready var mainMenu = $MainMenu
onready var settingsMenu = $SettingsMenu
onready var videoSettings = $SettingsMenu/Menu/SettingsContainer/VideoSettings
onready var audioSettings = $SettingsMenu/Menu/SettingsContainer/AudioSettings
onready var controlsSettings = $SettingsMenu/Menu/SettingsContainer/ControlSettings
onready var bgmAudioStream = $SettingsMenu/Menu/SettingsContainer/AudioSettings/BGMTestButton/BGMAudioStreamPlayer
onready var sfxAudioStream = $SettingsMenu/Menu/SettingsContainer/AudioSettings/SFXTestButton/SFXAudioStreamPlayer
onready var masterLabel = $SettingsMenu/Menu/SettingsContainer/AudioSettings/MasterValue
onready var bgmLabel = $SettingsMenu/Menu/SettingsContainer/AudioSettings/BGMValue
onready var sfxLabel = $SettingsMenu/Menu/SettingsContainer/AudioSettings/SFXValue
var config = ConfigFile.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hide_settings():
	videoSettings.hide()
	audioSettings.hide()
	controlsSettings.hide()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Map.tscn")


func _on_OptionsButton_pressed():
	mainMenu.hide()
	settingsMenu.popup()
	hide_settings()
	videoSettings.show()
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_VideoButton_pressed():
	print("a")
	hide_settings()
	videoSettings.show()


func _on_AudioButton_pressed():
	print("b")
	hide_settings()
	audioSettings.show()


func _on_ControlsButton_pressed():
	print("c")
	hide_settings()
	controlsSettings.show()


func _on_MasterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	masterLabel.text = String(value * 100)


func _on_BGMSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear2db(value))
	bgmLabel.text = String(value * 100)


func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(value))
	sfxLabel.text = String(value * 100)


func _on_BGMTestButton_pressed():
	bgmAudioStream.play()


func _on_SFXTestButton_pressed():
	sfxAudioStream.play()
