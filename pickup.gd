extends Node2D

enum ItemType {HEALTH,STAMINA,SPEED}
export (ItemType) var type	

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

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Player")):
		$"../../Player".get_node("PowerUpAnimationPlayer").stop(true)
		$"../../Player".get_node("PowerUpAnimationPlayer").play("PowerUp")
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
	pass

func PickupHealth():
	print("Picked Up Health")
	PlayerStats.set_max_health(PlayerStats.max_health + 1)
	PlayerStats.set_max_speed(PlayerStats.max_speed - 1)
	$"../../Player".get_node("PowerUpSprites").texture = load("res://health-speed.png")

func PickupStamina():
	print("Picked Up Stamina")
	PlayerStats.set_max_stamina(PlayerStats.max_stamina + 1)
	PlayerStats.set_max_health(PlayerStats.max_health - 1)
	$"../../Player".get_node("PowerUpSprites").texture = load("res://stamina-health.png")

func PickupSpeed():
	print("Picked Up Speed")
	PlayerStats.set_max_speed(PlayerStats.max_speed + 1)
	PlayerStats.set_max_stamina(PlayerStats.max_stamina - 1)
	PlayerStats.set_speed(PlayerStats.max_speed)
	$"../../Player".get_node("PowerUpSprites").texture = load("res://speed-stamina.png")
