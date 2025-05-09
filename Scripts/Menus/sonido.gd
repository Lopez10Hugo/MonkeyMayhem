extends Control

@onready var audio_slider: Control = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/audio_slider
@onready var sonido: Control = $"."
@onready var options_menu: Control = $".."

func _ready() -> void:
	print('ready')
	_on_focus_entered()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if sonido.is_visible_in_tree():
			options_menu._inicial_display()
			options_menu.grab_focus()
			get_viewport().set_input_as_handled()

func _on_button_pressed() -> void:
	options_menu._inicial_display()
	options_menu._on_focus_entered()


func _on_focus_entered() -> void:
	print('audio focus')
	audio_slider._on_focus_entered()
