extends Area2D

@export var speed: float = 500.0
var damage: int
var shooter: Node = null
var direction: Vector2 = Vector2.ZERO
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	pass

func _process(delta):
	#sprite_2d.rotation = direction.angle()
	position += direction * speed * delta
		# Ajustar flip horizontal
	if abs(direction.x) > abs(direction.y): # Horizontal
		sprite_2d.flip_h = direction.x < 0
		sprite_2d.rotation = 0
	else: # Vertical, si quieres rotar hacia arriba o abajo
		sprite_2d.rotation = direction.angle()

func set_direction(dir: Vector2):
	direction = dir.normalized()


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage)
		queue_free()
	else:
		queue_free()
