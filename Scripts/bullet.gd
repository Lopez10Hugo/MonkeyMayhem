extends Area2D

@export var speed: float = 500.0
@export var trail_enabled: bool = false
var damage: int
var shooter: Node = null
var direction: Vector2 = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Line2D
@onready var particles: GPUParticles2D = $GPUParticles2D
var start_position: Vector2
var lifetime = 0.0
var lifespan = 10.0
var has_collided := false

var previous_position: Vector2  # Nueva variable para rastrear la posición anterior

func _ready() -> void:
	start_position = global_position
	previous_position = global_position  # Iniciar el seguimiento
	particles.position.x *= direction.x
	particles.scale.x *= direction.x
	if trail_enabled:
		trail.clear_points()
		trail.width = 4.0
		trail.default_color = Color.WHITE
		trail.add_point(Vector2.ZERO)
		trail.add_point(Vector2.ZERO)

func _process(delta):
	if has_collided:
		return

	var new_position = global_position + direction * speed * delta

	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = previous_position
	query.to = new_position
	query.exclude = [self]
	query.collision_mask = collision_mask

	var result = space.intersect_ray(query)

	if result:
		_on_body_entered(result.collider)
		return  # Cancelar el movimiento tras colisión

	global_position = new_position
	previous_position = global_position

	if trail_enabled:
		trail.set_point_position(0, to_local(start_position))
		trail.set_point_position(1, Vector2.ZERO)

	# Rotación
	if abs(direction.x) > abs(direction.y):
		sprite_2d.flip_h = direction.x < 0
		sprite_2d.rotation = 0
	else:
		sprite_2d.rotation = direction.angle()

	lifetime += delta
	if lifetime > lifespan:
		queue_free()

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _on_body_entered(body):
	if has_collided:
		return  

	has_collided = true
	set_deferred("monitoring",false)  

	if body.is_in_group("Player"):
		body.take_damage(damage)
	else:
		particles.emitting = true
		sprite_2d.visible = false

		if trail_enabled:
			var p0 = trail.get_point_position(0)
			var p1 = trail.get_point_position(1)
			trail.clear_points()
			trail.add_point(p0)
			trail.add_point(p1)

		await get_tree().create_timer(0.2).timeout

	queue_free()
