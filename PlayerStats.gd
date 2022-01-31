extends Node2D

var default_max_health = 5	
var max_health = 5
var health
var default_max_stamina = 5
var max_stamina = 5
var stamina
var default_max_speed = -5
var max_speed = 5
var first_spawn = true
	
signal no_health
signal moonwalk
signal health_changed(value)
signal max_health_changed(value)

signal stamina_changed(value)
signal max_stamina_changed(value)

signal max_speed_changed(value)

func _ready():
	self.health = max_health
	self.stamina = max_stamina
	self.max_speed = max_speed

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		
func set_max_stamina(value):
	max_stamina = value
	self.stamina = min(stamina, max_stamina)
	emit_signal("max_stamina_changed", max_stamina)
	
func set_stamina(value):
	stamina = value
	emit_signal("stamina_changed", stamina)

func set_max_speed(value):
	max_speed = value
	emit_signal("max_speed_changed", max_speed)
	if max_speed <= -1 and BackgroundMusic.get_node("AudioStreamPlayer").stream != load("res://hat.WAV"):
		emit_signal("moonwalk")
		print("moonwalk")
	
func reset_stats():
	max_health = default_max_health
	health = default_max_health
	max_stamina = default_max_stamina
	stamina = default_max_stamina
	max_speed = default_max_speed
	emit_signal("health_changed", health)
	emit_signal("max_health_changed", max_health)
	emit_signal("stamina_changed", stamina)
	emit_signal("max_stamina_changed", max_stamina)
	emit_signal("max_speed_changed", max_speed)
