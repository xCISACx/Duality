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
	PlayerStats.health += 10
	PlayerStats.speed -= 10

func PickupStamina():
	print("Picked Up Stamina")
	PlayerStats.stamina += 10
	PlayerStats.health -= 10

func PickupSpeed():
	print("Picked Up Speed")
	PlayerStats.speed += 10
	PlayerStats.stamina -= 10
