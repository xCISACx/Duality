extends Node2D

var borders = Rect2(1, 1, 25, 25)

const barrel = preload("res://EnemyBarrel.tscn")
const mushroom = preload("res://EnemyMushroom.tscn")
onready var tile_map = $TileMap

func _ready():
	Variables.root = self
<<<<<<< Updated upstream
	BackgroundMusic.get_node("AudioStreamPlayer").play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
=======
	generate_level()
	
func generate_level():
	var walker = Walker.new(Vector2(19, 11), borders)
	var map = walker.walk(1000)
	walker.queue_free()
	for location in map:
		tile_map.set_cellv(location, -1)
		if randf() <= 0.05:
			generate_enemies(1, tile_map.map_to_world(location))
			
	tile_map.update_bitmask_region(borders.position, borders.end)
		
func generate_enemies(enemy_amount, location):
		if randf() < .5:
			var enemybarrel = barrel.instance()
			add_child(enemybarrel)
			enemybarrel.global_position = location
		else:
			var enemymushroom = mushroom.instance()
			add_child(enemymushroom)
			enemymushroom.global_position = location
	
func spawn_player():
	pass
>>>>>>> Stashed changes
