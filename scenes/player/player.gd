extends CharacterBody2D

@export var speed = 30
@export var terminal_velocity = 300
@export var drag = 10
@export var gravity = 10
@export var jump_velocity = 200
@export var max_jumps = 2
@export var start_position = Vector2(0, 0)

@onready var crouch_shapecast = $CrouchShapeCast2D
@onready var cshape = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var anim = $AnimationTree
@onready var jumpParticles = $Effects/jumpParticles

var jump_num = max_jumps
var is_crouching = false
var stuck_under_object = false

var standing_cshape = preload("res://scenes/player/StandingCollisionShape.tres")
var crouching_cshape = preload("res://scenes/player/CrouchCollisionShape.tres")


#this happens onece when load into the screen
func _ready():
	position = start_position
	anim.active = true


#executes every frame, for non physics processes
func _process(delta):
	if position.y > 500:
		position = start_position
	#print(position)


#executes every frame dealing with physics processes
func _physics_process(delta):
	#falling mechanics
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > terminal_velocity: #implement terminal velocity
			velocity.y = terminal_velocity
	else:
		jump_num = max_jumps #reset number of jumps if on floor
	
	#jumping mechanics
	if Input.is_action_just_pressed("jump") && jump_num > 0 && !is_crouching: 
		velocity.y = -jump_velocity
		jump_num -= 1
		jumpParticles.angle_max = 0 + 20
		jumpParticles.gravity = Vector2(velocity.x / 8, -velocity.y / 8)
		jumpParticles.emitting = 0 - 20
		

	
	#horixontal movement mechanics
	#horizontal direction is between -1 and 1 both or neither is 0
	var horizontal_direction = Input.get_action_strength("right") - Input.get_action_strength("left") 
	velocity.x += speed * horizontal_direction #adds the speed times direction to velocity
	velocity.x -= velocity.x * (drag*delta) 
	
	if velocity.x > terminal_velocity: #set terminal velocities
		velocity.x = terminal_velocity
	elif velocity.x< -terminal_velocity:
		velocity.x = -terminal_velocity
	if horizontal_direction != 0: #update animation
		switch_direction(horizontal_direction)
	
	
	
	#crouching mechanics
	if Input.is_action_just_pressed("crouch"):    #crouch
		crouch()
	elif Input.is_action_just_released("crouch"): #attempt to stand
		if above_head_is_empty():
			stand()
		else:
			stuck_under_object = true
	#test if still crouching after being able to stand, then stand 
	if stuck_under_object && !Input.is_action_pressed("crouch") && above_head_is_empty(): 
		stand()
		stuck_under_object = false
	
	
	move_and_slide()
	update_animations(horizontal_direction)


#uses the 2 raycasts to return true if there is nothing on top
func above_head_is_empty() -> bool:
	return !crouch_shapecast.is_colliding()


#updates the corresponding animation in the AnimateSprite2D
func update_animations(horizontal_direction):
	if is_on_floor():
		anim.set("parameters/in_air_state/transition_request", "ground") #ground
	else:
		anim.set("parameters/in_air_state/transition_request", "air") #air
	
	if horizontal_direction == 0: 
		anim.set("parameters/movement/transition_request", "static") #not moving
	else:
		anim.set("parameters/movement/transition_request", "moving") #moving
		
	if is_crouching:
		anim.set("parameters/static_crouching/transition_request", "crouch") #crouch
		anim.set("parameters/air_crouch/transition_request", "crouch") #air crouch
	else:
		anim.set("parameters/static_crouching/transition_request", "idle") #idle
		anim.set("parameters/moving_crouching/transition_request", "run") #run
		anim.set("parameters/air_crouch/transition_request", "air") #no air crouch
		
	if velocity.y < 0: #y negative is going up
		anim.set("parameters/was_in_air/transition_request", "jump") #jump
	else:
		anim.set("parameters/was_in_air/transition_request", "fall") #fall


#flips the animation direction to left or right depending on the direction of movement
func switch_direction(horizontal_direction): 
	sprite.flip_h = (horizontal_direction < 0) #uses horizontal direction to become a boolean
	sprite.position.x = horizontal_direction #4 is the offset of the sprite from center


#updates the boolean and collision shape when crouching
func crouch():
	if !is_crouching:
		is_crouching = true
		anim.set("crouch_walk_time", 0.5) #set the animation speed to half
		speed /= 2 #set speed to normal
		cshape.shape = crouching_cshape
		cshape.position.y = -10.5


#updates the boolean and collision shape when standing
func stand():
	if is_crouching:
		is_crouching = false
		anim.set("crouch_walk_time", 1) #set the animation speed to normal
		speed *= 2 #set speed to normal
		cshape.shape = standing_cshape
		cshape.position.y = -15
