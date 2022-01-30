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
onready var optionsButton = $SettingsMenu/Menu/SettingsContainer/VideoSettings/VideoOptionsButton
var config = ConfigFile.new()
var testing = false

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
	get_tree().change_scene("res://Main.tscn")


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
	if testing == false:
		bgmAudioStream.play()
		testing = true
	else:
		bgmAudioStream.stop()
		sfxAudioStream.stop()
		testing = false


func _on_SFXTestButton_pressed():
	if testing == false:
		sfxAudioStream.play()
		testing = true
	else:
		bgmAudioStream.stop()
		sfxAudioStream.stop()
		testing = false


func _on_CloseButton_pressed():
	mainMenu.show()
	settingsMenu.hide()
	
# Emitted when the selected resolution changes.
signal resolution_changed(new_resolution)

func _update_selected_item(text: String) -> void:
	# The resolution options are written in the form "XRESxYRES".
	# Using `split_floats` we get an array with both values as floats.
	var values := text.split_floats("x")
	# Emit a signal for informing the newly selected resolution
	emit_signal("resolution_changed", Vector2(values[0], values[1]))

func _on_VideoOptionsButton_item_selected(index):
	_update_selected_item(optionsButton.text)
	
# Emitted when the user presses the "apply" button.
signal apply_button_pressed(settings)

# We store the selected settings in a dictionary
var _settings := {resolution = Vector2(1280, 720), fullscreen = false, vsync = false}

# Emit the `apply_button_pressed` signal, when user presses the button.
func _on_ApplyButton_pressed() -> void:
	# Send the last selected settings with the signal
	print("apply")
	emit_signal("apply_button_pressed", _settings)
	update_settings(_settings)

func _on_FullscreenCheckBox_toggled(button_pressed):
	_settings.fullscreen = button_pressed

func _on_StartMenu_resolution_changed(new_resolution):
	_settings.resolution = new_resolution
	
func update_settings(settings: Dictionary) -> void:
	OS.window_fullscreen = settings.fullscreen
	#get_tree().set_screen_stretch(
	#	SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, settings.resolution
	#)
	#OS.set_window_size(settings.resolution)
