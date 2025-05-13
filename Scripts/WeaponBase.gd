extends Area2D
class_name WeaponBase

@export var weapon_name: String
@export var damage: int
@export var is_melee: bool
@export var throw_speed: float
@export var sprite_texture: Texture2D

var is_equipped: bool = false
var velocity: Vector2 = Vector2.ZERO
var can_attack: bool = true
var damaged_bodies := []
var is_attacking: bool = false


func _ready():
	if has_node("Sprite2D"):
		$Sprite2D.texture = sprite_texture

func _on_body_entered(body):
	if body.is_in_group("Player") and not body.Hand.get_children().filter(func(c): return c.name.begins_with("WeaponBase")).size() > 0 and not is_equipped:
		is_equipped = true
		call_deferred("_equip_to_hand", body)
	elif is_attacking and body.is_in_group("Player") and body not in damaged_bodies and self.get_parent().get_parent() != body:
		body.take_damage(damage)
		damaged_bodies.append(body)

func _equip_to_hand(body):
	get_parent().remove_child(self)
	body.Hand.add_child(self)
	global_position = body.Hand.global_position
	
func attack():
	damaged_bodies.clear()
	$CooldownTimer.start()
	$AttackTimer.start()

func _on_cooldown_timer_timeout() -> void:
	can_attack = true
	
func _on_attack_timer_timeout() -> void:
	is_attacking = false
	set_monitoring(false)
