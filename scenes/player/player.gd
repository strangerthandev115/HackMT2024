extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_TIMES = 2

var jumpCount = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	print(is_on_floor())
	# Add the gravity.
	if not is_on_floor() && jumpCount < JUMP_TIMES:
		velocity.y += gravity * delta
		jumpCount = jumpCount + 1
	if is_on_floor():
		jumpCount = 0


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
