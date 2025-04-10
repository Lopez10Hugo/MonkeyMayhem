extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton

const RESOLUTON_DICTIONARY : Dictionary = {
	"1280x620" : Vector2i(1280,620),
	"1280x720" : Vector2i(1280,720),
	"1920x1080" : Vector2i(1920,1080)
}

func _ready():
	option_button.item_selected.connect(on_resolucion_seleccionada)
	add_resolution_items()

func add_resolution_items() -> void:
	for resolucion in RESOLUTON_DICTIONARY:
		option_button.add_item(resolucion)

func on_resolucion_seleccionada(index : int) -> void:
	DisplayServer.window_set_size(RESOLUTON_DICTIONARY.values()[index])

func _on_focus_entered() -> void:
	option_button.grab_focus()
