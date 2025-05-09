extends WeaponBase
class_name Pistol

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.5
@onready var fire_timer: Timer = $CooldownTimer

func _ready():
	super._ready()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true

func attack():
	if can_attack:
		can_attack = false
		fire_timer.start()
		shoot_bullet()

func shoot_bullet():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = global_rotation
		bullet.set_direction(Vector2.RIGHT.rotated(global_rotation))  # Assuming bullet uses this method
		get_tree().current_scene.add_child(bullet)
