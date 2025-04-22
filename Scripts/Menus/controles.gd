extends Control
@onready var rebind_control: rebind_control = $MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Rebind_control
@onready var options_menu: Control = $".."
@onready var controles: Control = $"."
@onready var volver_al_menu: Button = $"MarginContainer/VBoxContainer2/Volver al menu"

func _on_focus_entered() -> void:
	print('rebind control grabbed focus')
	rebind_control._on_focus_entered()



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if controles.is_visible_in_tree():
			options_menu._inicial_display()
			options_menu.grab_focus()
			get_viewport().set_input_as_handled()

func _on_volver_al_menu_pressed() -> void:
	options_menu._inicial_display()

func _on_focus_exited() -> void:
	if controles.is_visible_in_tree():
		print('volver al menu grabbed focus')
		volver_al_menu.grab_focus()
