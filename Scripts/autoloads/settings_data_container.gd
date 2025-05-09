extends Node

@onready var DEFAULT_SETTING : DefaultSettingsResource = preload("res://Scripts/Menus/recursos/DefaultSettings.tres")

var window_mode_index : int = 0
var resolution_index : int = 0
var master_volume : float = 0
var music_volume : float = 0
var effects_volume : float = 0
var subtitles_state : bool = false
var loaded_data : Dictionary = {}

func _ready() -> void:
	handle_signals()
	create_storage_dict()

func create_storage_dict() -> Dictionary:
	var settings_dict : Dictionary = {
		"window_mode_index" : window_mode_index,
		"resolution_index" : resolution_index,
		"master_volume" : master_volume,
		"music_volume" : music_volume,
		"effects_volume" : effects_volume,
		"subtitles_state" : subtitles_state,
		"slow_motion_enabled" : SeleccionPersonaje.slow_motion_enabled,
		"high_contrast_enabled": SeleccionPersonaje.high_contrast_enabled
	}
	
	return settings_dict

func get_window_mode_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTING.DEFAULT_WINDOW_MODE_INDEX
	return window_mode_index

func get_resolution_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTING.DEFAULT_RESOLUTION_MODE_INDEX
	return resolution_index

func get_master_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTING.DEFAULT_MASTER_VOLUME
	return master_volume

func get_music_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTING.DEFAULT_MUSIC_VOLUME
	return music_volume

func get_effects_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTING.DEFAULT_EFFECTS_VOLUME
	return effects_volume

func get_subtitles_set() -> bool:
	if loaded_data == {}:
		return DEFAULT_SETTING.DEFAULT_SUBTITLES_SET
	return subtitles_state

func get_slow_motion_set()->bool:
	if loaded_data == {}:
		return SeleccionPersonaje.slow_motion_enabled
	return SeleccionPersonaje.slow_motion_enabled

func get_high_contrast_set() -> bool:
	if loaded_data == {}:
		return SeleccionPersonaje.high_contrast_enabled
	return SeleccionPersonaje.high_contrast_enabled

func on_window_mode_selected(index : int) -> void:
	window_mode_index = index

func on_resolution_mode_selected(index : int) -> void:
	resolution_index = index

func on_subtitles_set(toggled : bool) -> void:
	subtitles_state = toggled

func on_master_sound_set(value : float) -> void:
	master_volume = value

func on_musica_sound_set(value : float) -> void:
	music_volume = value

func on_efectos_sound_set(value : float) -> void:
	effects_volume = value

func on_slow_motion_set(toggled : bool) -> void:
	SeleccionPersonaje.slow_motion_enabled = toggled

func on_high_contrast_set(toggled : bool) -> void:
	SeleccionPersonaje.high_contrast_enabled = toggled


func on_settings_data_loaded(data : Dictionary) -> void:
	loaded_data = data
	on_window_mode_selected(loaded_data.window_mode_index)
	on_resolution_mode_selected(loaded_data.resolution_index)
	on_master_sound_set(loaded_data.master_volume)
	on_musica_sound_set(loaded_data.music_volume)
	on_efectos_sound_set(loaded_data.effects_volume)
	on_subtitles_set(loaded_data.subtitles_state)
	if "high_contrast_enabled" in loaded_data:
		on_high_contrast_set(loaded_data.high_contrast_enabled)
	else:
		on_high_contrast_set(SeleccionPersonaje.high_contrast_enabled)
		
	if "high_contrast_enabled" in loaded_data:
		on_slow_motion_set(loaded_data.slow_motion_enabled)
	else:
		on_slow_motion_set(SeleccionPersonaje.slow_motion_enabled)
	

func handle_signals() -> void:
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_selected.connect(on_resolution_mode_selected)
	SettingsSignalBus.on_subtitles_toggled.connect(on_subtitles_set)
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_musica_sound_set.connect(on_musica_sound_set)
	SettingsSignalBus.on_efectos_sound_set.connect(on_efectos_sound_set)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
	SettingsSignalBus.on_slow_motion_toggled.connect(on_slow_motion_set)
	SettingsSignalBus.on_high_contrast_toggled.connect(on_high_contrast_set)
	
