extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 160
export var FRICTION = 500

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitbox = $"HitBoxPivot/SwordHitBox"
onready var shieldHitbox = $"ShieldHitBoxPivot/ShieldHitBox"
onready var collsword = $"HitBoxPivot/SwordHitBox/CollisionShape2D"
onready var collshield = $"ShieldHitBoxPivot/ShieldHitBox/CollisionShape2D"
onready var hurtbox = $"HurtBox"
onready var stamina_timer = $StaminaTimer
onready var stamina_timeout_timer = $StaminaTimeout
onready var flashAnimationPlayer = $FlashAnimationPlayer
onready var hat = $InconspicousHat
onready var hat_clip = load("res://hat.WAV")
onready var deathUI = get_tree().root.get_node("/root/Main/CanvasLayer/Death UI/UI")
onready var playerUI = get_tree().root.get_node("/root/Main/CanvasLayer/Player UI")

var stats = PlayerStats

enum {
	MOVE,
	ROLL,
	ATTACK,
	GUARD,
	DEATH
}

var state = MOVE
var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO;
var roll_vector = Vector2.DOWN;
var guard_vector = Vector2.DOWN;
var knockback = Vector2.ZERO
var guarding = false

signal player_dead

func _init():
	GameManager.player = self

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
		GUARD:
			guard_state(delta)
		DEATH:
			death_state()
	#print(velocity)
	
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	$Pointer.hide()
	GameManager.player = self
	animation_tree.set("parameters/Attack/blend_position", Vector2.DOWN)
	animation_tree.set("parameters/Roll/blend_position", Vector2.DOWN)
	animation_tree.set("parameters/Death/blend_position", Vector2.DOWN)
	animation_tree.set("parameters/Guard/blend_position", Vector2.DOWN)
	collshield.disabled = true
	
	if BackgroundMusic.get_node("AudioStreamPlayer").playing != true: 
		if PlayerStats.max_speed > -1:
			hat.hide()
			BackgroundMusic.get_node("AudioStreamPlayer").stream = load("res://bgm.wav")
			BackgroundMusic.get_node("AudioStreamPlayer").play()
		else:
			BackgroundMusic.get_node("AudioStreamPlayer").stream = hat_clip
			BackgroundMusic.get_node("AudioStreamPlayer").play()
			
	if PlayerStats.max_speed > -1:
		hat.hide()
	else:
		hat.show()
		
	set_max_speed(PlayerStats.max_speed)
	PlayerStats.set_max_health(PlayerStats.max_health)
	PlayerStats.set_health(PlayerStats.health)
	Variables.player = self
	randomize()
	animation_tree.active = true
	PlayerStats.connect("max_speed_changed", self, "set_max_speed")
	PlayerStats.connect("no_health", self, "death_state")
	PlayerStats.connect("moonwalk", self, "show_hat")
	playerUI.connect("speed_changed", self, "hat_check")
	var pause_menu = get_tree().root.get_node("/root/Main/CanvasLayer/Pause Menu")
	pause_menu.connect("unpaused", self, "reset_guard")
	collsword.disabled = true
	$HurtBox/CollisionShape2D.disabled = false
	$PowerUpBackAnimatedSprite.visible = false
	$PowerUpFrontAnimatedSprite.visible = false
	pass # Replace with function body.

func _input(event):
	if event.is_action_released("guard"):
		if guarding:
			stats.set_stamina(stats.stamina - 1)
			print("released guard")
			collshield.disabled = true
			guarding = false
			if stats.stamina >= 1:
				stamina_timer.start()
			elif stats.stamina < 1:
				stamina_timeout_timer.start()
				stamina_timer.stop()
			state = MOVE
		
	
func move_state(delta):
	if (input_vector != Vector2.ZERO):
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Walk/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_tree.set("parameters/Death/blend_position", input_vector)
		animation_tree.set("parameters/Guard/blend_position", input_vector)
		
		animation_state.travel("Walk")
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	collshield.disabled = true
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
			
	if Input.is_action_pressed("guard"):
		print("pressed guard")
		if stats.stamina > 0:
			if stats.stamina < 1:
				stamina_timeout_timer.start()
				stamina_timer.stop()
			else:
				stamina_timer.start()
			state = GUARD
		else:
			print("Can't guard!")

	if (Input.is_action_just_pressed("attack")):
		state = ATTACK
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_state():
	if PlayerStats.max_speed >= 0:
		velocity = roll_vector * ROLL_SPEED
	else:
		velocity = roll_vector * -ROLL_SPEED
	animation_state.travel("Roll")
	move()
	
func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")
	
func reset_guard():
	collshield.disabled = true
	guarding = false
	if state != DEATH:
		state = MOVE
	
func guard_state(delta):
	animation_state.travel("Guard")
	#print(input_vector)
	guard_vector = animation_tree.get("parameters/Guard/blend_position")
	guarding = true
	#print("can move")
	velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	stamina_timer.stop()
	if stats.stamina < 1:
		break_guard()
	move()

func death_state():
	velocity = Vector2.ZERO
	state = DEATH
	animation_state.travel("Death")
	emit_signal("player_dead")
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	$HurtBox/CollisionShape2D.disabled = false
	velocity = velocity * 0.8
	state = MOVE
	
func set_max_speed(value):
	MAX_SPEED = value * 20
	#print(MAX_SPEED)
	
func break_guard():
	collshield.disabled = true
	guarding = false
	state = MOVE
	print("guard broken!")
	stamina_timeout_timer.start()
	stamina_timer.stop()

func _on_HurtBox_area_entered(area):
	var hit_direction = global_position.direction_to(area.global_position)
	var dot = hit_direction.dot(guard_vector)
	print(hit_direction.dot(guard_vector))
	if guarding && dot > 0:
		print("player shielded")
		stats.set_stamina(stats.stamina - 1)
	else:
		PlayerStats.set_health(PlayerStats.health - area.damage)
		knockback = area.knockback_vector * 120
		#hurtbox.create_hit_effect()
		hurtbox.start_invincibility(0.4)
		#print(PlayerStats.health)
	
func _on_HurtBox_invincibility_started():
	if state != DEATH:
		flashAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	if state != DEATH:
		flashAnimationPlayer.play("Stop")
	
func _on_StaminaTimer_timeout():
	if (stats.stamina < stats.max_stamina):
		stats.set_stamina(stats.stamina + 1)

func _on_StaminaTimeout_timeout():
	stamina_timer.start()
	
func hat_check():
	if PlayerStats.max_speed > -1:
		hat.hide()
		if !BackgroundMusic.get_node("AudioStreamPlayer").playing:
			if !BackgroundMusic.get_node("AudioStreamPlayer").stream == load("res://bgm.wav"):
					BackgroundMusic.get_node("AudioStreamPlayer").stream = load("res://bgm.wav")
					BackgroundMusic.get_node("AudioStreamPlayer").play()
		elif BackgroundMusic.get_node("AudioStreamPlayer").playing:
			if BackgroundMusic.get_node("AudioStreamPlayer").stream == load("res://hat.WAV"):
				BackgroundMusic.get_node("AudioStreamPlayer").stop()
				BackgroundMusic.get_node("AudioStreamPlayer").stream = load("res://bgm.wav")
				BackgroundMusic.get_node("AudioStreamPlayer").play()
	elif PlayerStats.max_speed < 0:
		hat.show()
		if BackgroundMusic.get_node("AudioStreamPlayer").playing:
			if !BackgroundMusic.get_node("AudioStreamPlayer").stream == load("res://hat.WAV"):
				BackgroundMusic.get_node("AudioStreamPlayer").stream = load("res://hat.WAV")
				BackgroundMusic.get_node("AudioStreamPlayer").play()
	
func show_hat():
	hat.visible = true
	BackgroundMusic.get_node("AudioStreamPlayer").stream = hat_clip
	if !BackgroundMusic.get_node("AudioStreamPlayer").is_playing():
		BackgroundMusic.get_node("AudioStreamPlayer").play()
	else:
		print("already playing")
