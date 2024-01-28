extends CharacterBody2D

@export var terminal_velocity = 300
@export var gravity = 10

@onready var sprite = $AnimatedSprite2D
@onready var anim = $AnimationPlayer

var patrolSpeed = 20
var chaseSpeed = 40
var direction = 1
var state = 'patrol'
var substate = 'idle'
var idle_countdown_initial = 20.0
var idle_countdown: float
var health = 3
# var aggro_radius = 200
var player_in_aggro_radius = false
var player_in_attack_attempt_radius = false
var finishedAnimation = false
# var harming_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	idle_countdown = idle_countdown_initial
	anim.play("Idle")

# Updates sprite animation to the specified animation
func set_animation(a):
	finishedAnimation = false # Reset animation-finished flag whenever new animation starts
	# $AnimatedSprite2D.animation = a
	anim.play(a)

func attack_attempt_check():
	return player_in_attack_attempt_radius

# Detect if a patrolling skeleton has reached a wall or ledge
func stopping_point():
	if !$LedgeDetector.is_colliding() || $WallDetector.is_colliding():
		return true
	return false

# Turns skeleton in opposite direction; used when patrolling
func flip_character():
	direction *= -1
	scale.x *= -1

# Sets Skeleton sprite to face a specified direction; used when chasing
func set_sprite_facing(posneg):
	direction *= -1
	if posneg > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func patrol_behavior(delta):
	if player_in_aggro_radius:
		state = 'aggro'
		substate = 'reacting'
		return
	
	if substate == 'idle':
		if idle_countdown <= 0:
			idle_countdown -= delta
		else:
			idle_countdown = idle_countdown_initial
			substate = 'walk'
			set_animation("Walk")
	elif substate == 'walk':
		if stopping_point():
			flip_character()
			substate = 'idle'
			set_animation("Idle")

func physics_patrol_behavior(delta):
	if substate == 'walk' and not stopping_point():
		position += delta * patrolSpeed * direction * Vector2(1, 0)
		
func hit_by_player():
	# TODO: Implement hit detection
	return false

func aggro_behavior():
	if hit_by_player() and substate != 'hit':
		health -= 1
		if health == 0:
			state = 'dying'
			return
		substate = 'hit'
	
	if substate == 'hit':
		if finishedAnimation:
			substate = 'chase'
			set_animation("Walk")
	
	if substate == 'reacting':
		if finishedAnimation:
			substate = 'chase'
			set_animation("Walk")
	
	if attack_attempt_check() and substate != 'attacking':
		substate = 'attacking'
	
	if substate == 'attacking':
		if finishedAnimation:
			# TODO: enable hurt box
			# TODO: disable hurt box
			substate = 'chase'
			set_animation("Walk")
	
	if substate == 'chase':
		set_sprite_facing(relative_player_direction)

#func barrier_collision():
	## TODO: Detect collision with wall or other obstruction
	#return false

func relative_player_direction():
	var player_node = get_node("res://player/player.tscn")
	var player_xpos = player_node.global_position.x
	var skeleton_xpos = self.global_position.x
	if player_xpos < skeleton_xpos:
		return -1
	return 1

func physics_aggro_behavior(delta):
	if substate == 'chase': # and not barrier_collision():
		position += delta * chaseSpeed * relative_player_direction() * Vector2(1, 0)
		pass

func die_behavior():
	if finishedAnimation:
		queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == 'patrol':
		patrol_behavior(delta)
	elif state == 'aggro':
		aggro_behavior()
	elif state == 'dying':
		die_behavior()
	
func _physics_process(delta):
	$Hurtbox2.angular_damp_space_override = $Hurtbox2.angular_damp_space_override
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > terminal_velocity: #implement terminal velocity
			velocity.y = terminal_velocity
	move_and_slide()
	if state == 'patrol':
		physics_patrol_behavior(delta)
	elif state == 'aggro':
		physics_aggro_behavior(delta)
	

func _on_detection_radius_body_entered(body):
#	if body.name == 'player':
#		body.die()
#		player_in_aggro_radius = true
	if body.has_method("die"):
		body.die()


func _on_animated_sprite_2d_animation_finished():
	finishedAnimation = true


func _on_attack_attempt_radius_body_entered(body):
	if body.name == 'player':
		player_in_attack_attempt_radius = true


func _on_attack_attempt_radius_body_exited(body):
	if body.name == 'player':
		player_in_attack_attempt_radius = false
