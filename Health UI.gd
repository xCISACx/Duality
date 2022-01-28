extends Control

var hearts = 5 setget set_hearts
var max_hearts = 5 setget set_max_hearts

var stamina_icons = 5 setget set_stamina
var max_stamina = 5 setget set_max_stamina

var speed_icons = 5 setget set_speed
var max_speed = 5 setget set_max_speed

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var staminaUIFull = $StaminaUIFull
onready var staminaUIEmpty = $StaminaUIEmpty
onready var speedUIFull = $SpeedUIFull
onready var speedUIEmpty = $SpeedUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull:
		heartUIFull.rect_size.x = hearts * 15
		
func set_stamina(value):
	stamina_icons = clamp(value, 0, max_stamina)
	if staminaUIFull:
		staminaUIFull.rect_size.x = stamina_icons * 15
		
func set_speed(value):
	speed_icons = clamp(value, 0, max_speed)
	if speedUIFull:
		speedUIFull.rect_size.x = speed_icons * 15
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty:
		heartUIEmpty.rect_size.x = max_hearts * 15
		
func set_max_stamina(value):
	max_stamina = max(value, 1)
	self.stamina_icons = min(stamina_icons, max_stamina)
	if staminaUIEmpty:
		staminaUIEmpty.rect_size.x = max_stamina * 15
		
func set_max_speed(value):
	max_speed = max(value, 1)
	self.speed_icons = min(speed_icons, max_speed)
	if speedUIEmpty:
		speedUIEmpty.rect_size.x = max_speed * 15
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	self.max_stamina = PlayerStats.max_stamina
	self.stamina_icons = PlayerStats.stamina
	self.max_speed = PlayerStats.max_speed
	self.speed_icons = PlayerStats.speed
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	PlayerStats.connect("stamina_changed", self, "set_stamina")
	PlayerStats.connect("max_stamina_changed", self, "set_max_stamina")
	PlayerStats.connect("speed_changed", self, "set_speed")
	PlayerStats.connect("max_speed_changed", self, "set_max_speed")
	
