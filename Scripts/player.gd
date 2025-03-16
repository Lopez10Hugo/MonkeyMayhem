extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_BUFFER_WINDOW = 5
const COYOTE_FRAME_WINDOW = 5

var jump_pressed = false
var coyote_counter = 0
var jump_buffer_counter = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		coyote_counter = 0
		if jump_pressed and jump_buffer_counter <= JUMP_BUFFER_WINDOW:
			velocity.y = JUMP_VELOCITY
			jump_pressed = false
	else:
		velocity += get_gravity() * delta
		coyote_counter += 1
		jump_buffer_counter += 1

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		jump_pressed = true
		jump_buffer_counter = 0
		if is_on_floor() or coyote_counter <= COYOTE_FRAME_WINDOW:
			velocity.y = JUMP_VELOCITY
			
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
