extends CharacterBody2D

const SPEED = 300.0
const JUMP_BUFFER_WINDOW = 0.08
const COYOTE_FRAME_WINDOW = 0.08
const CLIMB_SPEED = 300.0  # Velocidad de trepado

var jump_pressed = false
var coyote_counter = 0
var jump_buffer_counter = 0

@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var is_climbing = false  # Estado de trepado

func _physics_process(delta: float) -> void:
	# Comprobar si está tocando una pared
	var is_touching_wall = is_on_wall()

	# Movimiento y gravedad
	if is_on_floor():
		coyote_counter = 0
		if jump_pressed and jump_buffer_counter <= JUMP_BUFFER_WINDOW:
			velocity.y = jump_velocity
			jump_pressed = false
		if is_climbing:
			# Detener el movimiento de gravedad mientras trepa
			velocity.y = 0
	else:
		# Si no está tocando el suelo, aplicar gravedad
		velocity.y += calculate_gravity() * delta
		coyote_counter += delta 
		jump_buffer_counter += delta

	# Comportamiento de salto
	if Input.is_action_just_pressed("ui_accept") and not is_climbing:
		jump_pressed = true
		jump_buffer_counter = 0
		if is_on_floor() or coyote_counter <= COYOTE_FRAME_WINDOW:
			velocity.y = jump_velocity

	# Comportamiento de trepar
	if is_touching_wall and Input.is_action_pressed("Trepar") and Input.is_action_pressed("ui_accept"):
		# Si el jugador está tocando la pared y presiona "W + Espacio", activar el trepado
		is_climbing = true
		velocity.y = -CLIMB_SPEED  # Subir la pared
	else:
		is_climbing = false
		velocity.x = SPEED  # Si no está tocando la pared o no presiona las teclas, dejar de trepar

	# Movimiento horizontal usando WASD
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func calculate_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
