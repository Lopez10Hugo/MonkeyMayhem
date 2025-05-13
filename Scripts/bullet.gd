extends Area2D

@export var speed: float = 500.0
var damage: int

var direction: Vector2 = Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage)
		queue_free()
