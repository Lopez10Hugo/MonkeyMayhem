extends Area2D
class_name WeaponBase

@export var weapon_name: String
@export var damage: int
@export var is_melee: bool
@export var throw_speed: float
@export var sprite_texture: Texture2D

var is_equipped: bool = false
var velocity: Vector2 = Vector2.ZERO

func _ready():
	if has_node("Sprite2D"):
		$Sprite2D.texture = sprite_texture

func _on_body_entered(body):
	if body.is_in_group("Player") and not is_equipped:
		is_equipped = true
		get_parent().remove_child(self)      
		body.Hand.add_child(self)                  
		global_position = body.Hand.global_position 
