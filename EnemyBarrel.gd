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
onready var last_position = global_position

onready var sprite = $Sprite
#onready var wanderController = $WanderController
onready var playerDetectionZone = $PlayerDetectionZone
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var state = IDLE

enum {
	IDLE,
	CHASE
}

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
			print("chase")
			var space_state = get_world_2d().direct_space_state
			if player:
				var result = space_state.intersect_ray(global_position, player.global_position, [self])
				#if result.is_in_group("")
					
			if player != null and can_move:
				accelerate_towards_point(player.global_position, delta)
				print("go to player")
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
				
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front() #pick the first random result
	
func toggle_apex():
	apex = !apex
	
func start_wait_timer():
	$Timer.start()
	can_move = false

func _on_Timer_timeout():
	can_move = true
	
func _process(delta):
	#print($Timer.time_left)
	pass
