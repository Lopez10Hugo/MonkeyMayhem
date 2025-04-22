extends Control

@onready var estado: Label = $HBoxContainer/Estado
@onready var check_button: CheckButton = $HBoxContainer/CheckButton

func _ready():
	load_data()

func load_data() -> void:
	_on_check_button_toggled(SettingsDataContainer.get_subtitles_set())
	check_button.button_pressed = SettingsDataContainer.get_subtitles_set()

func set_label_text(button_pressed : bool) ->void:
	if button_pressed != true:
		estado.text = "off"
	else:
		estado.text = "on"

func _on_check_button_toggled(toggled_on: bool) -> void:
	set_label_text(toggled_on)
	SettingsSignalBus.emit_on_subtitles_toggled(toggled_on)

func _on_focus_entered() -> void:
	print('check button grabbed focus')
	check_button.grab_focus()
