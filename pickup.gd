extends Node2D

enum ItemType {HEALTH,STAMINA,SPEED}
export (ItemType) var type	
var player_in_range = false
onready var player = Variables.player

func _ready():
	
	match(type):
			ItemType.HEALTH:
				$Sprite.texture = load("res://item_health-speed.png")
				pass
			ItemType.STAMINA:
				$Sprite.texture = load("res://item_stamina-health.png")
				pass
			ItemType.SPEED:
				$Sprite.texture = load("res://item_speed-stamina.png")
				pass

func _process(delta):
	if player_in_range:
		if Input.is_action_just_pressed("pick_up"):
			pick_up()
			
func pick_up():
	player.get_node("PowerUpAnimationPlayer").stop(true)
	player.get_node("PowerUpAnimationPlayer").play("PowerUp")
	match(type):
		ItemType.HEALTH:
			queue_free()
			PickupHealth()
			pass
		ItemType.STAMINA:
			queue_free()
			PickupStamina()
			pass
		ItemType.SPEED:
			PickupSpeed()
			queue_free()
			pass
	
func _on_Area2D_body_entered(body):
	if (body.is_in_group("Player")):
		player_in_range = true
	pass

func PickupHealth():
	print("Picked Up Health")
	PlayerStats.set_max_health(PlayerStats.max_health + 1)
	PlayerStats.set_max_speed(PlayerStats.max_speed - 1)
	player.get_node("PowerUpSprites").texture = load("res://health-speed.png")

func PickupStamina():
	print("Picked Up Stamina")
	PlayerStats.set_max_stamina(PlayerStats.max_stamina + 1)
	PlayerStats.set_max_health(PlayerStats.max_health - 1)
	player.get_node("PowerUpSprites").texture = load("res://stamina-health.png")

func PickupSpeed():
	print("Picked Up Speed")
	PlayerStats.set_max_speed(PlayerStats.max_speed + 1)
	PlayerStats.set_max_stamina(PlayerStats.max_stamina - 1)
	PlayerStats.set_speed(PlayerStats.max_speed)
	player.get_node("PowerUpSprites").texture = load("res://speed-stamina.png")
