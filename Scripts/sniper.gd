extends WeaponBase

@onready var Sprite = $Sprite2D
@onready var shoot_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var laser_ray: RayCast2D = $LaserRay
@onready var laser_line: Line2D = $LaserLine
@onready var camera := get_viewport().get_camera_2d() # Asegúrate de que tu cámara está activa en el viewport
var tween: Tween

func _ready():
	weapon_name = "Sniper"
	damage = 50
	is_melee = false
	sprite_texture = preload("res://.godot/imported/laser_rifle_by_ashmo.png-d744b7e4ed36763e5b4047e818b7803d.ctex")
	laser_line.default_color = Color(1, 0, 0)  # Rojo normal
	laser_line.width = 2

	tween = create_tween() # Solo uno por ahora
	tween.kill() # Lo detenemos de inicio
	super._ready()

func _process(_delta):
	if is_equipped:
		update_laser_visual()
	super._process(_delta)

func attack():
	if not can_attack or is_attacking:
		return
	can_attack = false
	is_attacking = true
	apply_laser_damage()
	flash_laser_effect()
	shoot_sound.play()
	camera_shake()
	super.attack()

func update_laser_visual():
	var direction = Vector2.LEFT
	if Sprite.flip_h:
		direction.x *= -1

	laser_ray.target_position = direction * 1000
	laser_ray.force_raycast_update()

	var start_pos = laser_ray.global_position
	var end_pos = start_pos + laser_ray.target_position

	if laser_ray.is_colliding():
		end_pos = laser_ray.get_collision_point()

	laser_line.clear_points()
	laser_line.scale.x = -1 if Sprite.flip_h else 1
	laser_line.add_point(Vector2.ZERO)
	laser_line.add_point(laser_line.to_local(end_pos))

func apply_laser_damage():
	if laser_ray.is_colliding():
		var hit = laser_ray.get_collider()
		if hit and hit.is_in_group("Player") and hit.has_method("take_damage"):
			hit.take_damage(damage)

func flash_laser_effect():
	# Destello blanco y grueso
	laser_line.default_color = Color(1, 1, 1)
	laser_line.width = 5

	# Retroceso suave
	var recoil = Vector2(-10, 0) if Sprite.flip_h else Vector2(10, 0)
	var recoil_pos = position + recoil

	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", recoil_pos, 0.08).as_relative() # ir hacia atrás
	tween.tween_property(self, "position", position, 0.1) # volver

	await get_tree().create_timer(0.05).timeout

	# Volver a rojo y tamaño normal
	laser_line.default_color = Color(1, 0, 0)
	laser_line.width = 2

func camera_shake():
	if not camera:
		return
	var shake_tween = create_tween()
	var original_offset = camera.offset
	var shake_strength = 6

	for i in range(4):
		var random_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_tween.tween_property(camera, "offset", original_offset + random_offset, 0.03)
	shake_tween.tween_property(camera, "offset", original_offset, 0.05)
