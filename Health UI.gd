extends Control

var hearts = 5 setget set_hearts
var max_hearts = 5 setget set_max_hearts

var stamina_icons = 5 setget set_stamina
var max_stamina = 5 setget set_max_stamina

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var staminaUIFull = $StaminaUIFull
onready var staminaUIEmpty = $StaminaUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull:
		heartUIFull.rect_size.x = hearts * 15
		
func set_stamina(value):
	stamina_icons = clamp(value, 0, max_stamina)
	if staminaUIFull:
		staminaUIFull.rect_size.x = stamina_icons * 15
	
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
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	self.max_stamina = PlayerStats.max_stamina
	self.stamina_icons = PlayerStats.stamina
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	PlayerStats.connect("stamina_changed", self, "set_stamina")
	PlayerStats.connect("max_stamina_changed", self, "set_max_stamina")
