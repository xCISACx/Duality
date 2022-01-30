extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_THRESHOLD = 4

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var last_position = global_position
var hit_position = Vector2.ZERO
var player = null
var can_shoot = true
var pickup = load("res://Pickup.tscn")

onready var sprite = $Sprite
onready var wanderController = $WanderController
onready var playerDetectionZone = $PlayerDetectionZone
onready var animationTree = $AnimationTree
onready var raycast_node = $RayCast2D
onready var reset_timer = $ResetTimer
onready var shoot_timer = $ShootingTimer
onready var animationState = animationTree.get("parameters/playback")
const BulletScene = preload("res://BulletScene.tscn")
onready var enemystat = $EnemyStat

signal start_invincibility

var state = IDLE

enum {
	IDLE,
	WANDER,
	CHASE,
	ATTACK
}

func _ready():
	state = pick_random_state([IDLE, WANDER])
	enemystat.connect("no_health", self, "death")
	
func _physics_process(delta):		
	match state:
		IDLE:
			shoot_timer.stop()
			animationState.travel("idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			animationState.travel("wander")
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_THRESHOLD:
				update_wander()
				last_position = global_position
				
		CHASE:
			if reset_timer.time_left <= .35 and reset_timer.time_left > .15:
				_on_reset_timer_timeout()
			
			animationState.travel("chase")
			if player:
				if reset_timer.is_stopped():
					reset_timer.start()
				if raycast_for_player() or global_position.distance_to(player.position) < 10: #if the enemy sees the player
					if global_position.distance_to(player.position) < 80:
						reset_timer.start() #stop the player reset timer
						state = ATTACK
				else:
					accelerate_towards_point(player.global_position, delta)
						
			else:
				seek_player()
				accelerate_towards_point(last_position, delta)
				if global_position.distance_to(last_position) <= 5:
					state = IDLE
					
					
		ATTACK:
			if reset_timer.time_left <= .35 and reset_timer.time_left > .15:
				shoot_timer.stop()
				state = CHASE
			print("attacking")
			if raycast_for_player() or global_position.distance_to(player.position) < 10:
				reset_timer.start()
				if shoot_timer.is_stopped():
					can_shoot = true
				velocity = Vector2.ZERO
				animationState.travel("attack")
				if player and can_shoot:
					var direction_to_player = global_position.direction_to(player.global_position)
					shoot_towards(direction_to_player)
			elif global_position.distance_to(player.position) > 30:
				state = CHASE
				
				
	velocity = move_and_slide(velocity)
	print(reset_timer.time_left)
	print(state)
	if player:
		print(raycast_for_player())
			
			
func shoot_towards(direction):
	var bullet = BulletScene.instance()
	get_tree().get_root().add_child(bullet)
	bullet.position = global_position
	bullet.direction = direction
	bullet.get_node("Pivot").rotation_degrees = direction.angle()
	can_shoot = false
	shoot_timer.start()
			
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		player = playerDetectionZone.player
		state = CHASE
		#print("chase")
		
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
				
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front() #pick the first random result
	
func raycast_for_player() -> bool:
	var direction_to_player = global_position.direction_to(player.global_position)
	raycast_node.set_cast_to(direction_to_player * 100)
	var hit_object = raycast_node.get_collider()
	
	if hit_object:
		#print("hit something")
		if hit_object.is_in_group("Player"):
			#print("hit player")
			return true
		elif hit_object.is_in_group("Walls"):
			#print("hit wall")
			return false
	return false
	
func _on_reset_timer_timeout():
	print("set player to null")
	playerDetectionZone.player = null
	player = null


func _on_ShootingTimer_timeout():
	can_shoot = true
	
func death():
	var enemydrop = pickup.instance()
	var randomint = randi() % 2
	match (randomint):
		0:
			enemydrop.type = 0
		1:
			enemydrop.type = 1
		2:
			enemydrop.type = 2
	Variables.root.add_child(enemydrop)
	enemydrop.position = global_position
	queue_free()
	
func _on_HurtBox_area_entered(area):
	enemystat.set_health(enemystat.health - area.damage)
	emit_signal("start_invincibility")
	print(enemystat.health)
