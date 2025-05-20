extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton
#@onready var volver_al_menu: Button = $"MarginContainer/VBoxContainer/Volver al menu"

const WINDOW_MODE_ARRAY : Array[String] = [
	"Pantalla completa",
	"Ventana",
	"Ventana sin bordes",
	"Pantalla completa sin bordes"
]

func _ready() -> void:
	add_window_mode_items()
	option_button.item_selected.connect(on_modo_ventana_seleccionado)
	load_data()

func load_data() -> void:
	on_modo_ventana_seleccionado(SettingsDataContainer.get_window_mode_index())
	option_button.select(SettingsDataContainer.get_window_mode_index())

func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		option_button.add_item(window_mode)

func on_modo_ventana_seleccionado(index : int) -> void:
	SettingsSignalBus.emit_on_window_mode_selected(index)
	match index:
		0: #full screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		1: # ventana
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		2: # ventana sin bordes
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)
		3: # full screen sin bordes
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)

func _on_focus_entered() -> void:
	#print('option button 1 grabbed focus')
	option_button.grab_focus()
