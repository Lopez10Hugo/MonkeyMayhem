extends WeaponBase

func _ready():
	weapon_name = "Espada"
	damage = 50
	is_melee = true
	sprite_texture = preload("res://Assets/Weapons/chainsaw_by_ashmo.png")
	scale = Vector2(0.3, 0.3) 

	super._ready()

var attack_tween: Tween

func attack():
	if not can_attack or is_attacking:
		return
	can_attack = false
	is_attacking = true
	set_monitoring(true)
	attack_tween = create_tween()

	var original_rotation := rotation

	attack_tween.tween_property(self, "rotation", original_rotation + deg_to_rad(30), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(self, "rotation", original_rotation + deg_to_rad(-30), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	attack_tween.tween_property(self, "rotation", original_rotation, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await attack_tween.finished

	super.attack()
