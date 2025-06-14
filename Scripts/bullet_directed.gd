extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@export var speed: float = 400.0
var damage: int
var shooter: Node = null
var initial_direction: Vector2 = Vector2.ZERO
var target: Node = null
var life_time := 0.0
var delay_before_tracking := 0.2  
var turn_speed := 3.0 

var current_direction: Vector2 = Vector2.ZERO  

func _process(delta):
	sprite_2d.rotation = current_direction.angle() + PI
	collision.rotation = current_direction.angle() + PI
	life_time += delta
	if life_time < delay_before_tracking:
		# Primero va en la dirección inicial
		position += initial_direction * speed * delta
		current_direction = initial_direction
	else:
		# Después de cierto tiempo, empieza a buscar al objetivo más cercano
		if target == null:
			target = get_nearest_target()
		if target:
			var target_direction = (target.global_position - global_position).normalized()
			# Interpolación suave de la dirección hacia el objetivo
			current_direction.x = lerp(current_direction.x, target_direction.x, turn_speed * delta)
			current_direction.y = lerp(current_direction.y, target_direction.y, turn_speed * delta)
			position += current_direction * speed * delta

func set_direction(dir: Vector2):
	initial_direction = dir.normalized()
	current_direction = initial_direction

func get_nearest_target() -> Node:
	var players = get_tree().get_nodes_in_group("Player")
	var closest: Node = null
	var min_dist = INF

	for p in players:
		# No seleccionar al jugador que disparó
		if p == shooter:
			continue
		if p.is_dead:
			continue
		# Seleccionar al jugador más cercano
		var dist = global_position.distance_squared_to(p.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = p
	return closest

func _on_body_entered(body):
	# Asegurarse de que no colisiona con el jugador que disparó
	if body.is_in_group("Player") and body != shooter:
		body.take_damage(damage)
		queue_free()
	else:
		queue_free()
