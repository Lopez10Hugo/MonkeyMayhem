extends Control

@onready var options_menu: Control = $".."
@onready var graficos: Control = $"."
@onready var boton_modo_ventana: Control = $MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/boton_modo_ventana
@onready var volver_al_menu: Button = $"MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/Volver al menu"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if graficos.is_visible_in_tree():
			options_menu._inicial_display()
			options_menu.grab_focus()
			get_viewport().set_input_as_handled()

func _on_focus_entered() -> void:
	boton_modo_ventana.grab_focus()
	print('modo ventana grabbed focus')

func _on_volver_al_menu_pressed() -> void:
	options_menu._inicial_display()
	options_menu._on_focus_entered()
