extends Node

const SETTINGS_SAVE_PATH : String = "user://SettingsData.save"

var settings_data_dict : Dictionary = {}

func _ready() -> void:
	SettingsSignalBus.set_settings_dict.connect(on_settings_save)
	load_settings_data()

func on_settings_save(data : Dictionary) -> void:
	var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.WRITE, "MonoJuego")
	var json_data = JSON.stringify(data)
	
	save_settings_data_file.store_line(json_data)

func load_settings_data() -> void:
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return
	
	var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH,FileAccess.READ,"MonoJuego")
	var loaded_data : Dictionary = {}
	
	while save_settings_data_file.get_position() < save_settings_data_file.get_length():
		var json_string = save_settings_data_file.get_line()
		var json = JSON.new()
		var _parsed_result = json.parse(json_string)
		
		loaded_data = json.get_data()
		#print(loaded_data)
		
	SettingsSignalBus.emit_load_settings_data(loaded_data)
