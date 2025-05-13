extends Node

@onready var fondo: ParallaxBackground = $ParallaxBackground

@export var camera_path: NodePath = "Camera2D"
@onready var imagen_fondo: Sprite2D = $ParallaxBackground/ParallaxLayer/Sprite2D


func _process(delta: float) -> void:
	if has_node(camera_path):
		var cam = get_node(camera_path)
		if cam is Camera2D:
			fondo.scroll_offset = cam.global_position
			
			imagen_fondo.scale = cam.zoom * Vector2(2,2)
