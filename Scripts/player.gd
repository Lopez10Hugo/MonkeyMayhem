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
var airborne = false
var just_jumped : bool = false

var puede_moverse : bool = true

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

@onready var jump_sound: AudioStreamPlayer2D = $jump_sound
@onready var landing_sound: AudioStreamPlayer2D = $landing_sound
@onready var throw_sound: AudioStreamPlayer2D = $throw_sound
@onready var dash_sound: AudioStreamPlayer2D = $dash_sound
var recoil_velocity := Vector2.ZERO
var recoil_timer := 0.0
var recoil_duration := 0.1

func apply_recoil(force: Vector2):
	recoil_velocity = force
	recoil_timer = recoil_duration

func _physics_process(delta):
	if recoil_timer > 0:
		velocity += recoil_velocity
		recoil_timer -= delta
	check_ground(delta)
	if puede_moverse:
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
		if airborne:
			$BounceParticles.emitting = true
			landing_sound.play()
		airborne = false
		if dash_ready:
			can_dash = true
		coyote_counter = 0
		if jump_pressed and jump_buffer_counter <= JUMP_BUFFER_WINDOW:
			velocity.y = jump_velocity
			jump_pressed = false
	else:
		airborne = true
		velocity.y += calculate_gravity() * delta
		coyote_counter += delta 
		jump_buffer_counter += delta

func is_climbing():
	return check_for_wall() and Input.is_action_pressed("trepar_%s" % [player_id])

func handle_jump() -> void:
	if Input.is_action_just_pressed("saltar_%s" % [player_id]):
		jump_pressed = true
		jump_buffer_counter = 0
		if is_on_floor() or coyote_counter <= COYOTE_FRAME_WINDOW or is_climbing():
			just_jumped = true
			velocity.y = jump_velocity
			jump_sound.play()

func handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("dash_%s" % [player_id]) and not dashing and can_dash:
		dashing = true
		can_dash = false
		dash_ready = false
		dash_cooldown.start(1)
		dash_timer.start(0.2)
		dash_sound.play()
		var direction_x = Input.get_axis("mover_izquierda_%s" % [player_id], "mover_derecha_%s" % [player_id])
		var direction_y = Input.get_axis("trepar_arriba_%s" % [player_id], "trepar_abajo_%s" % [player_id])
		var dash_direction = Vector2(direction_x, direction_y).normalized()
		if dash_direction == Vector2.ZERO:
			dash_direction.x = 1 if Sprite.flip_h else -1
		velocity = dash_direction * SPEED * 3
		for i in range(3):  
			await get_tree().create_timer(0.05 * i).timeout
			create_trail()
	
	if is_climbing() and not just_jumped:
		velocity.y = calculate_wall_movement() * CLIMB_SPEED * delta
	elif not dashing:
		var direction := Input.get_axis("mover_izquierda_%s" % [player_id], "mover_derecha_%s" % [player_id])
		if direction:
			#print(velocity)
			velocity.x = move_toward(velocity.x,direction * SPEED,SPEED)
		else:
			#print(velocity)
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
		child = candidates.front()
		
	if child != null:
		child.get_node("Sprite2D").flip_h = Sprite.flip_h
		if Sprite.flip_h:
			child.position.x = Hand.position.x + 5
		else:
			child.position.x = Hand.position.x - 5

	update_collision_position_while_climbing()
	update_animation()

func update_collision_position_while_climbing():
	if is_climbing():
		var offset = 12 
		$Sprite2D.position.x = offset if Sprite.flip_h else -offset
	else:
		$Sprite2D.position.x = 0

var walking_started = false
var last_state = ""

func update_animation():
	if is_climbing():
		if $Sprite2D.animation != "climb":
			$Sprite2D.play("climb")
		walking_started = false
		last_state = "climb"

	elif velocity.x != 0 and is_on_floor():
		if last_state != "walk-init" and not walking_started:
			$Sprite2D.play("walk-init")
			last_state = "walk-init"
			walking_started = true
		elif $Sprite2D.animation == "walk-init" and !$Sprite2D.is_playing():
			$Sprite2D.play("walk-cycle")
			last_state = "walk-cycle"
	else:
		if $Sprite2D.animation != "idle":
			$Sprite2D.play("idle")
		walking_started = false
		last_state = "idle"


func create_trail():
	var trail_sprite = AnimatedSprite2D.new()
	trail_sprite.sprite_frames = $Sprite2D.sprite_frames
	trail_sprite.animation = $Sprite2D.animation
	trail_sprite.frame = $Sprite2D.frame
	trail_sprite.global_position = $Sprite2D.global_position
	trail_sprite.scale = $Sprite2D.scale
	trail_sprite.modulate = Color(0.6, 0.4, 0.2, 0.8)
	trail_sprite.z_index = $Sprite2D.z_index - 1
	trail_sprite.flip_h = $Sprite2D.flip_h
	
	get_parent().add_child(trail_sprite)
	
	var tween = get_tree().create_tween()
	tween.tween_property(trail_sprite, "modulate", Color(0.6, 0.4, 0.2, 0), 0.3)
	tween.tween_callback(trail_sprite.queue_free)

func _on_dash_timer_timeout() -> void:
	dashing = false
	velocity.x = 0
	velocity.y /= 10

func take_damage(damage: int):
	HP -= damage
	_flash_red()
	if HP <= 0:
		explode()

func _flash_red():
	var sprite = $Sprite2D
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

func explode():
	if is_dead:
		return
	$CollisionShape2D.set_deferred("disabled", true)
	$ExplosionParticles.emitting = true
	$Sprite2D.visible = false
	set_physics_process(false)
	set_process(false)
	await get_tree().create_timer(1.0).timeout
	visible = false
	is_dead = true

func lanzar_arma(weapon):
	if not weapon:
		return

	var thrown_weapon = preload("res://Scenes/WeaponThrown.tscn").instantiate()
	thrown_weapon.global_position = weapon.global_position
	thrown_weapon.damage = weapon.damage
	thrown_weapon.sprite_texture = weapon.sprite_texture
	thrown_weapon.initial_scale = weapon.scale

	var dir = Vector2(1 if Sprite.flip_h else -1, 0).normalized()
	thrown_weapon.linear_velocity = dir * 500
	thrown_weapon.damaged_players.append(self)
	get_parent().add_child(thrown_weapon)
	weapon.queue_free()

func handle_attack():
	var child: Node = null
	var candidates = Hand.get_children().filter(func(c): return c.name.begins_with("WeaponBase"))
	if candidates.size() > 0:
		child = candidates.front()
	if Input.is_action_pressed("atacar_%s" % [player_id]) and child != null:
		child.attack()
	if Input.is_action_pressed("lanzar_arma_%s" % [player_id]) and child != null:
		lanzar_arma(child)
		throw_sound.play()

func _on_cooldown_dash_timer_timeout() -> void:
	dash_ready = true

func _on_sprite_2d_animation_finished() -> void:
	if $Sprite2D.animation == "walk-init":
		$Sprite2D.play("walk-cycle")
		last_state = "walk-cycle"
