extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitbox = $"HitBoxPivot/SwordHitBox"
onready var collsword = $"HitBoxPivot/SwordHitBox/CollisionShape2D"
onready var hurtbox = $"HurtBox"
onready var stamina_timer = $StaminaTimer
onready var stamina_timeout_timer = $StaminaTimeout
onready var flashAnimationPlayer = $FlashAnimationPlayer

var stats = PlayerStats

enum {
	MOVE,
	ROLL,
	ATTACK,
	DEATH
}

var state = MOVE
var velocity = Vector2.ZERO;
var roll_vector = Vector2.DOWN;
var knockback = Vector2.ZERO

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
		DEATH:
			death_state()
	print("invincible: " + String($HurtBox.invincible))
		

# Called when the node enters the scene tree for the first time.
func _ready():
	Variables.player = self
	randomize()
	animation_tree.active = true
	PlayerStats.connect("max_speed_changed", self, "set_max_speed")
	PlayerStats.connect("no_health", self, "death_state")
	collsword.disabled = true
	$HurtBox/CollisionShape2D.disabled = false
	$PowerUpBackAnimatedSprite.visible = false
	$PowerUpFrontAnimatedSprite.visible = false
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
		animation_tree.set("parameters/Death/blend_position", input_vector)
		
		animation_state.travel("Walk")
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		if stats.stamina >= 1:
			stats.set_stamina(stats.stamina - 1)
			if stats.stamina < 1:
				stamina_timeout_timer.start()
				stamina_timer.stop()
			else:
				stamina_timer.start()
			state = ROLL
		else:
			print("Can't roll!")

	if (Input.is_action_just_pressed("attack")):
		state = ATTACK
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("Roll")
	move()
	
func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func death_state():
	velocity = Vector2.ZERO
	state = DEATH
	animation_state.travel("Death")
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	$HurtBox/CollisionShape2D.disabled = false
	velocity = velocity * 0.8
	state = MOVE
	
func set_max_speed(value):
	MAX_SPEED = value * 20
	print(MAX_SPEED)

func _on_HurtBox_area_entered(area):
	PlayerStats.set_health(PlayerStats.health - area.damage)
	knockback = area.knockback_vector * 120
	#hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	print(PlayerStats.health)
	
func _on_HurtBox_invincibility_started():
	flashAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	flashAnimationPlayer.play("Stop")
	
func _on_StaminaTimer_timeout():
	if (stats.stamina < stats.max_stamina):
		stats.set_stamina(stats.stamina + 1)

func _on_StaminaTimeout_timeout():
	stamina_timer.start()
	

	
