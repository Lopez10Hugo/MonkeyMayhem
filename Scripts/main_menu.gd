extends Control

@onready var options_menu: Control = $"Options Menu"
@onready var fondo_main: Panel = $Background
@onready var margin_container_main: MarginContainer = $MarginContainer

func _ready() -> void:
	options_menu.exit_options.connect(on_exit_options)
	

func on_exit_options() -> void:
	margin_container_main.visible = true
	fondo_main.visible = true
	options_menu.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_options_pressed() -> void:
	margin_container_main.visible = false
	fondo_main.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()
