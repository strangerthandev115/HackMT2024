extends Node2D
var patrolSpeed = 20
var chaseSpeed = 40
var direction = 1
var state = 'patrol'
var substate = 'idle'
var idle_countdown_initial = 20.0
var idle_countdown: float
var health = 3
var aggro_radius = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	idle_countdown = idle_countdown_initial

func aggro_check():
	# TODO: Check if player is in aggro radius
	return false
	
func attack_attempt_check():
	# TODO: Check if player is in attack attempt radius
	return false

func stopping_point():
	# TODO: Detect wall or ledge for character to turn around at
	return false
	
func flip_character():
	direction *= -1
	# TODO: Flip sprite

func patrol_behavior(delta):
	if aggro_check():
		state = 'aggro'
		substate = 'reacting'
		return
	
	if substate == 'idle':
		if idle_countdown <= 0:
			idle_countdown -= delta
		else:
			idle_countdown = idle_countdown_initial
			substate = 'walk'
			# TODO: Change animation to walking
	elif substate == 'walk':
		if stopping_point():
			flip_character()
			substate = 'idle'
			# TODO: Change animation to idle

func physics_patrol_behavior(delta):
	if substate == 'walk' and not stopping_point():
		# TODO: x_position += delta * patrolSpeed * direction
		pass
		
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
		if true: # TODO: If animation complete
			substate = 'chase'
			# TODO: Set animation to chase animation
	
	if substate == 'reacting':
		# Advance reacting animation
		if true: # TODO: If animation complete
			substate = 'chase'
			# TODO: Set animation to chase animation
	
	if attack_attempt_check() and substate != 'attacking':
		substate = 'attacking'
	
	if substate == 'attacking':
		if true: # TODO: If animation complete
			# TODO: enable hurt box
			# TODO: disable hurt box
			substate = 'chase'

func barrier_collision():
	# TODO: Detect collision with wall or other obstruction
	return false

func relative_player_direction():
	# TODO: Return 1 if player to the right; -1 if player to the left
	return 1

func physics_aggro_behavior(delta):
	if substate == 'walk' and not barrier_collision():
		# TODO: x_position += delta * chaseSpeed * relative_player_direction()
		pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == 'patrol':
		patrol_behavior(delta)
	elif state == 'aggro':
		pass
	elif state == 'dying':
		pass
	
func _physics_process(delta):
	if state == 'patrol':
		physics_patrol_behavior(delta)
	elif state == 'aggro':
		pass
