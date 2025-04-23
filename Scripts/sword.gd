extends WeaponBase

func _ready():
	weapon_name = "Espada"
	damage = 25
	is_melee = true
	sprite_texture = preload("res://Assets/Weapons/chainsaw_by_ashmo.png")
	scale = Vector2(0.3, 0.3) 

	super._ready()
