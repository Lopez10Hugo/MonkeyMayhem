extends Control

@onready var volver: Button = $MarginContainer/ScrollContainer/VBoxContainer/volver
@onready var options_menu: Control = $".."
@onready var accesibilidad: Control = $"."
@onready var slow_motion: CheckButton = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/slow_motion
@onready var high_contrast_check: CheckButton = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/high_contrast_check
@onready var slow_motion_state: Label = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/slow_motion_state
@onready var high_contrast_state: Label = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/high_contrast_state

func _ready() -> void:
	load_data()

func load_data():
	_on_slow_motion_toggled(SettingsDataContainer.get_slow_motion_set())
	slow_motion.button_pressed = SettingsDataContainer.get_slow_motion_set()
	
	_on_high_contrast_check_toggled(SettingsDataContainer.get_high_contrast_set())
	high_contrast_check.button_pressed = SettingsDataContainer.get_high_contrast_set()

func set_slow_motion_state(button_pressed: bool) -> void:
	if button_pressed:
		slow_motion_state.text = "On"
	else:
		slow_motion_state.text = "Off"

func set_high_contrast_state(button_pressed: bool) -> void:
	if button_pressed:
		high_contrast_state.text = "On"
	else:
		high_contrast_state.text = "Off"

func _on_focus_entered() -> void:
	print('toggle grabbed focus')
	high_contrast_check.grab_focus()

func _on_volver_pressed() -> void:
	options_menu._inicial_display()
	options_menu._on_focus_entered()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if accesibilidad.is_visible_in_tree():
			options_menu._inicial_display()
			options_menu.grab_focus()
			get_viewport().set_input_as_handled()

func _on_high_contrast_check_toggled(toggled_on: bool) -> void:
	#SeleccionPersonaje.high_contrast_enabled = toggled_on
	SettingsSignalBus.emit_on_high_contrast_toggled(toggled_on)
	set_high_contrast_state(toggled_on)

func _on_slow_motion_toggled(toggled_on: bool) -> void:
	#SeleccionPersonaje.high_contrast_enabled = toggled_on
	SettingsSignalBus.emit_on_slow_motion_toggled(toggled_on)
	set_slow_motion_state(toggled_on)
