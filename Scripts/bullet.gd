extends Area2D

@export var speed: float = 500.0
@export var trail_enabled: bool = false
var damage: int
var shooter: Node = null
var direction: Vector2 = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Line2D

var start_position: Vector2
var lifetime = 0.0
var lifespan = 10.0

func _ready() -> void:
	start_position = global_position  # Guardar origen real

	if trail_enabled:
		trail.clear_points()
		trail.width = 4.0
		trail.default_color = Color.WHITE
		trail.add_point(Vector2.ZERO)  # Punto inicial: origen (se actualiza más abajo)
		trail.add_point(Vector2.ZERO)  # Punto final: posición actual (se actualiza en _process)

func _process(delta):
	global_position += direction * speed * delta

	if trail_enabled:
		trail.set_point_position(0, to_local(start_position))           # Origen
		trail.set_point_position(1, Vector2.ZERO)                       # Actual (posición local)

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
	if body.is_in_group("Player"):
		body.take_damage(damage)
	queue_free()
