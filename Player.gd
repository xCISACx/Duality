extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitbox = $"HitBoxPivot/SwordHitBox"
onready var collsword = $"HitBoxPivot/SwordHitBox/CollisionShape2D"
onready var hurtbox = $"HurtBox/CollisionShape2D"

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO;
var roll_vector = Vector2.DOWN;

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
		

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	animation_tree.active = true
	PlayerStats.connect("max_speed_changed", self, "set_max_speed")
	collsword.disabled = true
	hurtbox.disabled = false
	pass # Replace with function body.
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if (input_vector != Vector2.ZERO):
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Walk/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		
		animation_state.travel("Walk")
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
#		if stats.stamina >= 1:
#			stats.stamina -= 1
#			if stats.stamina < 1:
#				stamina_timeout_timer.start()
#				stamina_timer.stop()
#			else:
#				stamina_timer.start()
			state = ROLL
#		else:
#			print("Can't roll!")

	if (Input.is_action_just_pressed("attack")):
		state = ATTACK
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("Roll")
	move()
	
func attack_state():
	#velocity = Vector2.ZERO
	animation_state.travel("Attack")
	move()
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	$HurtBox/CollisionShape2D.disabled = false
	velocity = velocity * 0.8
	state = MOVE
	
func set_max_speed(value):
	MAX_SPEED = value * 20
	print(MAX_SPEED)

