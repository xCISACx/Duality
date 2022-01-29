extends Area2D

var player = null
var chase_distance = 80
	
func can_see_player():
	return player

func _on_PlayerDetectionZone_body_entered(body):
	if player:
		return
	player = body
	print("entered")

func _physics_process(delta):
	var pos = global_position
	
	if player:
		pass
		#print(pos.distance_to(player.global_position))
		#if pos.distance_to(player.global_position) > chase_distance:
			#player = null
		
