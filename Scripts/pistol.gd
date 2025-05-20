extends WeaponBase

@export var bullet_scene: PackedScene
@onready var Sprite = $Sprite2D
@onready var shoot_sound_2 = $AudioStreamPlayer
@onready var shoot_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	weapon_name = "Pistol"
	damage = 1000
	is_melee = false
	sprite_texture = preload("res://.godot/imported/german_pistol_by_ashmo.png-95c4c228a40b81685587a28f659a6679.ctex")
	super._ready()

func attack():
	if not can_attack or is_attacking:
		return
	can_attack = false
	is_attacking = true
	shoot_bullet()
	super.attack()

func shoot_bullet():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = global_rotation
		if Sprite.flip_h:
			bullet.set_direction(Vector2.RIGHT.rotated(global_rotation)) 
		else:
			bullet.set_direction(Vector2.LEFT.rotated(global_rotation)) 
		bullet.damage = damage
		bullet.shooter = self.get_parent().get_parent()
		get_tree().current_scene.add_child(bullet)

		# Reproducir sonido de disparo
		#shoot_sound_2.play()
		shoot_sound.play()
		
