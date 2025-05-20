extends RigidBody2D
class_name WeaponThrown

@export var damage: int = 10
@export var sprite_texture: Texture2D
@export var initial_scale: Vector2 = Vector2.ONE
@export var rotation_speed: float = 30.0


var damaged_players: Array = []
var gravity_disabled_time: float = 0.5
var apply_gravity: bool = true
var apply_map_collision = false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Sprite2D.texture = sprite_texture
	scale = initial_scale
	$Sprite2D.scale = initial_scale
	angular_velocity = rotation_speed
	apply_gravity = false
	await get_tree().create_timer(gravity_disabled_time).timeout
	apply_gravity = true
	apply_map_collision = true
	# Dejar de girar cuando la gravedad esté activada
	angular_velocity = 0 if apply_gravity else rotation_speed
	await get_tree().create_timer(2).timeout
	_queue_destruction()

func _integrate_forces(state):
	if apply_gravity:
		state.linear_velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * state.step
		angular_velocity = 0

func _on_body_entered(body):
	if body in damaged_players:
		return
	elif body.is_in_group("Player"):
		damaged_players.append(body)
		body.take_damage(damage)
		_queue_destruction()
	elif apply_map_collision:
		_queue_destruction()

func _queue_destruction():
	$Sprite2D.visible = false
	$BounceParticles.global_position = global_position
	$BounceParticles.emitting = true
	await get_tree().create_timer(0.3).timeout  
	queue_free()
