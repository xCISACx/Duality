extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_THRESHOLD = 4

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var debug_vector1 = Vector2.ZERO
var debug_vector2 = Vector2.ZERO
var apex = false
var can_move = true
var player
var hit_position = Vector2.ZERO
var pickup = load("res://Pickup.tscn")
onready var last_position = global_position

onready var sprite = $Sprite
#onready var wanderController = $WanderController
onready var playerDetectionZone = $PlayerDetectionZone
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var hitbox = $HitBox2/CollisionShape2D
onready var enemystat = $EnemyStat
onready var flashAnimationPlayer = $FlashAnimationPlayer

signal start_invincibility

var state = IDLE

enum {
	IDLE,
	CHASE,
	ATTACK
}

func _ready():
	$AnimationTree.active = true
	$"PoundHitBox/CollisionShape2D".disabled = true
	enemystat.connect("no_health", self, "death")

func _physics_process(delta):		
	match state:
		IDLE:
			animationState.travel("idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			last_position = global_position
			seek_player()
			
		CHASE:
			var player = playerDetectionZone.player
			animationState.travel("attack")
			#print("chase")
			
			if player != null and can_move:
				var dir_to_player = global_position.direction_to(player.global_position)
				accelerate_towards_point(player.global_position - (dir_to_player * 25), delta)
				#print("go to player")
			elif player == null and can_move:
				accelerate_towards_point(last_position, delta)
				if global_position.distance_to(last_position) <= 5:
					state = IDLE	
				
	velocity = move_and_slide(velocity)
	#print(String(PlayerStats.max_speed))
			
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
				
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front() #pick the first random result
	
func toggle_apex():
	apex = !apex
	
func start_wait_timer():
	$PoundTimer.start()
	velocity = Vector2.ZERO
	can_move = false

func _on_Timer_timeout():
	can_move = true

func _process(delta):
	#print($Timer.time_left)
	pass
	
func death():
	var enemydrop = pickup.instance()
	var randomint = randi() % 3
	match (randomint):
		0:
			enemydrop.type = 0
		1:
			enemydrop.type = 1
		2:
			enemydrop.type = 2
	
	Variables.root.add_child(enemydrop)
	enemydrop.position = global_position
	EnemyStats.set_enemy_amount(GameManager.enemies_alive - 1)
	GameManager.total_enemies_slain = GameManager.total_enemies_slain + 1
	queue_free()

func _on_HurtBox_area_entered(area):
	enemystat.set_health(enemystat.health - area.damage)
	emit_signal("start_invincibility")
	$HurtBox.start_invincibility(0.4)
	#print(enemystat.health)

func _on_HurtBox_invincibility_started():
	flashAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	flashAnimationPlayer.play("Stop")

#func _on_PoundHitBox_area_entered(area):
#	if area.is_in_group("PlayerShield"):
#		print("enemy hit shield")
#		$PoundHitBox.damage = 0
#	elif area.is_in_group("PlayerHurtbox"):
#		print("enemy hit player")
#		$PoundHitBox.damage = 1
