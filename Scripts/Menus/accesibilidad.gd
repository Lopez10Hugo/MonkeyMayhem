extends Control

@onready var volver: Button = $MarginContainer/ScrollContainer/VBoxContainer/volver
@onready var options_menu: Control = $".."
@onready var accesibilidad: Control = $"."
@onready var subtitles_toggle_button: Control = $MarginContainer/ScrollContainer/VBoxContainer/subtitles_toggle_button

func _on_focus_entered() -> void:
	print('toggle grabbed focus')
	subtitles_toggle_button._on_focus_entered()

func _on_volver_pressed() -> void:
	options_menu._inicial_display()
	options_menu._on_focus_entered()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if accesibilidad.is_visible_in_tree():
			options_menu._inicial_display()
			options_menu.grab_focus()
			get_viewport().set_input_as_handled()
