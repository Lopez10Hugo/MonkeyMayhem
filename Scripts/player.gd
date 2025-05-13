extends CharacterBody2D

const SPEED = 200.0
const JUMP_BUFFER_WINDOW = 0.08
const COYOTE_FRAME_WINDOW = 0.08
const CLIMB_SPEED = 10000.0  

var jump_pressed = false
var coyote_counter = 0
var jump_buffer_counter = 0
var dashing = false
var can_dash = true
var dash_accel: float = 1
var dash_ready: bool = true
var HP: float = 100
var is_dead = false

var just_jumped : bool = false

@export var player_id = 1
@onready var Ray = $Ray
@onready var Sprite = $Sprite2D
@onready var Hand = $Hand
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var dash_timer = $DashTimer
@onready var dash_cooldown = $CooldownDashTimer

func _physics_process(delta: float) -> void:
	#print("ID : " , player_id, " Pos: " , position, "Health: ", HP)
	check_ground(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()
	handle_attack()
	just_jumped = false
	
func calculate_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func check_for_wall() -> bool:
	return Ray.is_colliding()

func calculate_wall_movement() -> float:
	return Input.get_axis("trepar_arriba_%s" % [player_id], "trepar_abajo_%s" % [player_id])

func check_ground(delta: float) -> void:
	if is_on_floor():
		if(dash_ready):
			can_dash = true
		coyote_counter = 0
		if jump_pressed and jump_buffer_counter <= JUMP_BUFFER_WINDOW:
			velocity.y = jump_velocity
			jump_pressed = false
	else:
		velocity.y += calculate_gravity() * delta
		coyote_counter += delta 
		jump_buffer_counter += delta

func is_climbing():
	return check_for_wall() and Input.is_action_pressed("trepar_%s" % [player_id])

func handle_jump() -> void:
	if Input.is_action_just_pressed("saltar_%s" % [player_id]):
		jump_pressed = true
		jump_buffer_counter = 0
		if is_on_floor() or coyote_counter <= COYOTE_FRAME_WINDOW or is_climbing() :
			just_jumped = true
			velocity.y = jump_velocity

func handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("dash_%s" % [player_id]) and not dashing and can_dash:
		dashing = true
		can_dash = false
		dash_ready = false
		dash_cooldown.start(2)
		dash_timer.start(0.2)
		var direction_x = Input.get_axis("mover_izquierda_%s" % [player_id],"mover_derecha_%s" % [player_id])
		var direction_y = Input.get_axis("trepar_arriba_%s" % [player_id], "trepar_abajo_%s" % [player_id])
		var dash_direction = Vector2(direction_x, direction_y).normalized()
		if dash_direction == Vector2.ZERO:
			dash_direction.x = 1 if Sprite.flip_h else -1
		velocity = dash_direction * SPEED * 3
		for i in range(3):  # Creates multiple trail instances
			await get_tree().create_timer(0.05 * i).timeout
			create_trail()
	
	if is_climbing() and not just_jumped:
		velocity.y = calculate_wall_movement() * CLIMB_SPEED * delta
	elif not dashing:
		var direction := Input.get_axis("mover_izquierda_%s" % [player_id],"mover_derecha_%s" % [player_id])
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x < 0:
		Sprite.flip_h = false
		Ray.rotation_degrees = 0.0  
		Hand.position.x = -10
		
	elif velocity.x > 0:
		Sprite.flip_h = true
		Ray.rotation_degrees = 180.0
		Hand.position.x = 14
		
	var child: Node = null
	var candidates = Hand.get_children().filter(func(c): return c.name.begins_with("WeaponBase"))
	if candidates.size() > 0:
		child= candidates.front()
		
	if child != null:
		child.get_node("Sprite2D").flip_h = Sprite.flip_h
		if Sprite.flip_h:
			child.position.x = Hand.position.x + 10
		else:
			child.position.x = Hand.position.x - 10

func create_trail():
	var trail_sprite = Sprite2D.new()
	trail_sprite.texture = Sprite.texture
	trail_sprite.global_position = Sprite.global_position
	trail_sprite.scale = Sprite.scale
	trail_sprite.modulate = Color(0.6, 0.4, 0.2, 0.8)  
	trail_sprite.z_index = Sprite.z_index - 1
	trail_sprite.flip_h = Sprite.flip_h
	get_parent().add_child(trail_sprite)
	var tween = get_tree().create_tween()
	tween.tween_property(trail_sprite, "modulate", Color(0.6, 0.4, 0.2, 0), 0.3)  


func _on_dash_timer_timeout() -> void:
	dashing = false
	velocity.x = 0
	velocity.y /=10

func take_damage(damage: int):
	HP -= damage
	if HP <= 0:
		explode()
		
func explode():
	if is_dead:
		return
	$ExplosionParticles.emitting = true
	$Sprite2D.visible = false
	set_physics_process(false)
	set_process(false)
	await get_tree().create_timer(1.0).timeout
	#queue_free()
	visible = false
	is_dead = true


func handle_attack():
	var child: Node = null
	var candidates = Hand.get_children().filter(func(c): return c.name.begins_with("WeaponBase"))
	if candidates.size() > 0:
		child= candidates.front()
	if Input.is_action_pressed("atacar_%s" % [player_id]) and child != null:
		child.attack()
	
	


func _on_cooldown_dash_timer_timeout() -> void:
	dash_ready = true
