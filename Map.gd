extends Node2D

var borders = Rect2(1, 1, 25, 25)

const barrel = preload("res://EnemyBarrel.tscn")
const mushroom = preload("res://EnemyMushroom.tscn")
const player = preload("res://Player.tscn")
const tree = preload("res://Tree.tscn")
const portal = preload("res://Portal.tscn")
onready var tile_map = $WallTileMap
onready var top_tile_map = $WallTopTileMap
var player_spawned = false
var player_spawn_location = Vector2.ZERO
var portal_spawned
var enemy_spawn_chance = 0
var map_size = 250

func _ready():
	randomize()
	Variables.root = self
	#BackgroundMusic.get_node("AudioStreamPlayer").play()
	generate_level()
	EnemyStats.connect("all_enemies_dead", self, "spawn_portal")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func generate_level():
	enemy_spawn_chance += 0.025
	GameManager.enemies_alive = 0
	var walker = Walker.new(Vector2(19, 11), borders)
	var map = walker.walk(map_size + 10)
	walker.queue_free()
	for location in map:
		tile_map.set_cellv(location, -1)
		top_tile_map.set_cellv(location, -1)
		if randf() <= enemy_spawn_chance:
			generate_enemies(1, tile_map.map_to_world(location))
			EnemyStats.set_enemy_amount(GameManager.enemies_alive + 1)
		elif !player_spawned:
			spawn_player(tile_map.map_to_world(location))
			player_spawn_location = location
	tile_map.update_bitmask_region(borders.position, borders.end)
	top_tile_map.update_bitmask_region(borders.position, borders.end)
		
func generate_enemies(enemy_amount, location):
		if randf() < .5:
			var enemybarrel = barrel.instance()
			add_child(enemybarrel)
			enemybarrel.global_position = location
		else:
			var enemymushroom = mushroom.instance()
			add_child(enemymushroom)
			enemymushroom.global_position = location
	
func spawn_player(location):
	var playerc = player.instance()
	add_child(playerc)
	playerc.global_position = location
	player_spawned = true
	pass
	
func spawn_portal():
	print("spawned portal")
	var portalc = portal.instance()
	add_child(portalc)
	var portal_location = player_spawn_location
	portalc.global_position = tile_map.map_to_world(portal_location)
	portal_spawned = true
	GameManager.portal_spawned = portal_spawned
	GameManager.player.get_node("Pointer").show()
	
