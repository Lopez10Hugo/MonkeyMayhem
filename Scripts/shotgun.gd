extends WeaponBase

@export var bullet_scene: PackedScene
@onready var Sprite = $Sprite2D
@onready var shoot_sound_2 = $AudioStreamPlayer
@onready var shoot_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	weapon_name = "Shotgun"
	damage = 10
	is_melee = false
	sprite_texture = preload("res://.godot/imported/mag7_by_ashmo.png-7aeca98bc61fe5809ccb6fc6392808f3.ctex")
	shoot_sound.stream = preload("res://Assets/Sounds/shootgun_shoot.mp3")
	super._ready()

func attack():
	if not can_attack or is_attacking:
		return
	can_attack = false
	is_attacking = true
	shoot_bullet()
	super.attack()
	play_recoil_animation()

func shoot_bullet():
	if bullet_scene:
		for i in range(10):
			var bullet = bullet_scene.instantiate()
			bullet.scale *= Vector2(0.2, 0.2)
			bullet.speed *= 3
			bullet.lifespan = 0.2
			bullet.trail_enabled = true
			var offset = Vector2(0, randf_range(-7, 7))
			bullet.global_position = global_position + offset

			var spread = deg_to_rad(randf_range(-10, 10))

			var base_direction = Vector2.LEFT
			if Sprite.flip_h:
				base_direction = Vector2.RIGHT

			var direction = base_direction.rotated(global_rotation + spread)

			bullet.set_direction(direction)
			bullet.rotation = direction.angle()
			bullet.damage = damage
			bullet.shooter = self.get_parent().get_parent()

			get_tree().current_scene.add_child(bullet)

		shoot_sound.play()

		# Empujar al jugador en dirección contraria al disparo (recoil)
		var player = self.get_parent().get_parent()  # asumimos que el jugador es el abuelo de la arma
		if player and player.has_method("apply_recoil"):
			var recoil_direction = (Vector2.RIGHT if Sprite.flip_h else Vector2.LEFT) * -1  # dirección opuesta al disparo
			player.apply_recoil(recoil_direction * 400) 

func play_recoil_animation():
	var start_rotation = rotation
	var recoil_angle = deg_to_rad(70)
	var recoil_rotation = start_rotation

	if Sprite.flip_h:
		recoil_rotation = start_rotation - recoil_angle
	else:
		recoil_rotation = start_rotation + recoil_angle

	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", recoil_rotation, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", start_rotation, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
