extends Node2D

enum ItemType {HEALTH,STAMINA,SPEED}
export (ItemType) var type

func _ready():
	pass

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Player")):
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
	PlayerStats.max_health += 1
	PlayerStats.max_speed -= 1

func PickupStamina():
	print("Picked Up Stamina")
	PlayerStats.max_stamina += 1
	PlayerStats.set_max_health(PlayerStats.max_health - 1)
	#PlayerStats.max_health -= 1

func PickupSpeed():
	print("Picked Up Speed")
	PlayerStats.max_speed += 1
	PlayerStats.max_stamina -= 1
