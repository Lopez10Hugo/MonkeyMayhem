extends WeaponBase

@export var bullet_scene: PackedScene
@onready var Sprite = $Sprite2D
@onready var shoot_sound = $AudioStreamPlayer

func _ready():
	weapon_name = "Minigun"
	damage = 10
	is_melee = false
	sprite_texture = preload("res://Assets/posibles armas/m1_carbine_by_ashmo.png")
	scale = Vector2(0.235, 0.235) 
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

		var base_dir = Vector2()
		if Sprite.flip_h:
			base_dir = Vector2.RIGHT.rotated(global_rotation)
		else:
			base_dir = Vector2.LEFT.rotated(global_rotation)

		var y_variation = randf_range(-0.1, 0.1)
		var direction = (base_dir + Vector2(0, y_variation)).normalized()

		bullet.set_direction(direction)
		bullet.damage = damage
		get_tree().current_scene.add_child(bullet)

		shoot_sound.play()
