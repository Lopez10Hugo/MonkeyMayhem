extends Control

@onready var volver_al_menu: Button = $"MarginContainer/VBoxContainer/Volver al menu"
@onready var options_menu: Control = $"."
@onready var boton_controles: Button = $MarginContainer/VBoxContainer/VBoxContainer/HSplitContainer/Controles
@onready var boton_graficos: Button = $MarginContainer/VBoxContainer/VBoxContainer/HSplitContainer/Graficos
@onready var graficos_tab: Control = $Graficos
@onready var controles_tab: Control = $Controles
@onready var boton_accesibilidad: Button = $MarginContainer/VBoxContainer/VBoxContainer/HSplitContainer2/Accesibilidad
@onready var boton_sonido: Button = $MarginContainer/VBoxContainer/VBoxContainer/HSplitContainer2/Sonido
@onready var sonido_tab: Control = $Sonido
@onready var accesibilidad_tab: Control = $Accesibilidad

signal exit_options

func _ready() -> void:
	# basicamente no ejecuta nada hasta que process sea true
	set_process(false)
	_inicial_display()

func _on_volver_al_menu_pressed() -> void:
	exit_options.emit()
	SettingsSignalBus.emit_set_settings_dict(SettingsDataContainer.create_storage_dict())
	set_process(false)

func _on_focus_entered() -> void:
	if controles_tab.is_visible_in_tree():
		controles_tab._on_focus_entered()
	elif sonido_tab.is_visible_in_tree():
		sonido_tab._on_focus_entered()
	elif graficos_tab.is_visible_in_tree():
		graficos_tab._on_focus_entered()
	elif accesibilidad_tab.is_visible_in_tree():
		accesibilidad_tab._on_focus_entered()
	else:
		#print('boton controles grabbed focus')
		boton_controles.grab_focus()

func _on_controles_pressed() -> void:
	_hide_botones()
	controles_tab.show()
	#print('controles tab grabbed focus')
	controles_tab._on_focus_entered()

func _on_graficos_pressed() -> void:
	_hide_botones()
	graficos_tab.show()
	graficos_tab._on_focus_entered()
	#print('graficos tab grabbes focus')

func _on_sonido_pressed() -> void:
	_hide_botones()
	sonido_tab.show()
	sonido_tab._on_focus_entered()

func _on_accesibilidad_pressed() -> void:
	_hide_botones()
	accesibilidad_tab.show()
	accesibilidad_tab._on_focus_entered()

func _inicial_display() -> void:
	graficos_tab.hide()
	controles_tab.hide()
	sonido_tab.hide()
	accesibilidad_tab.hide()
	boton_controles.show()
	boton_graficos.show()
	boton_accesibilidad.show()
	boton_sonido.show()
	volver_al_menu.show()

func _hide_botones() -> void:
	boton_controles.hide()
	boton_graficos.hide()
	boton_accesibilidad.hide()
	boton_sonido.hide()
	volver_al_menu.hide()
