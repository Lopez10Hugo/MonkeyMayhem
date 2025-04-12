extends Control

@onready var options_menu: Control = $"Options Menu"
@onready var fondo_main: Panel = $Background
@onready var margin_container_main: MarginContainer = $MarginContainer
@onready var boton_play: Button = $MarginContainer/VBoxContainer2/VBoxContainer/Start
@onready var main_menu: Control = $"."

func _ready() -> void:
	options_menu.exit_options.connect(on_exit_options)
	boton_play.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $"Options Menu".visible and not ($"Options Menu/Graficos".is_visible_in_tree() \
		or $"Options Menu/Controles".is_visible_in_tree() or $"Options Menu/Sonido".is_visible_in_tree()):
			on_exit_options()

func on_exit_options() -> void:
	margin_container_main.visible = true
	fondo_main.visible = true
	options_menu.visible = false
	boton_play.grab_focus()
	

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_options_pressed() -> void:
	margin_container_main.visible = false
	fondo_main.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	$"Options Menu".grab_focus()
	$"Options Menu"._inicial_display()

func _on_exit_pressed() -> void:
	get_tree().quit()
