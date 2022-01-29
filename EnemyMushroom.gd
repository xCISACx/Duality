extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_THRESHOLD = 4

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var last_position = global_position

onready var sprite = $Sprite
onready var wanderController = $WanderController
onready var playerDetectionZone = $PlayerDetectionZone
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var state = IDLE

enum {
	IDLE,
	WANDER,
	CHASE
}

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
func _physics_process(delta):		
	match state:
		IDLE:
			animationState.travel("idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			animationState.travel("move")
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_THRESHOLD:
				update_wander()
				last_position = global_position
				
		CHASE:
			animationState.travel("move")
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				accelerate_towards_point(last_position, delta)
				if global_position.distance_to(last_position) <= 5:
					state = IDLE
				
	velocity = move_and_slide(velocity)
			
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
				
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front() #pick the first random result
