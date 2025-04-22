extends Node

signal on_subtitles_toggled(value : bool)

signal on_window_mode_selected(index : int)

signal on_resolution_selected(index : int)

signal on_master_sound_set(value : float)

signal on_musica_sound_set(value : float)

signal on_efectos_sound_set(value : float)

signal set_settings_dict(settings_dict : Dictionary)

signal load_settings_data(settings_dict : Dictionary)

func emit_load_settings_data(settings_dict : Dictionary) ->void:
	load_settings_data.emit(settings_dict)

func emit_on_subtitles_toggled(value : bool):
	on_subtitles_toggled.emit(value)
	
func emit_on_window_mode_selected(index : int):
	on_window_mode_selected.emit(index)

func emit_on_resolution_selected(index : int):
	on_resolution_selected.emit(index)

func emit_on_master_sound_set(value : float):
	on_master_sound_set.emit(value)

func emit_on_musica_sound_set(value : float):
	on_musica_sound_set.emit(value)

func emit_on_efectos_sound_set(value : float):
	on_efectos_sound_set.emit(value)

func emit_set_settings_dict(settings_dict : Dictionary):
	set_settings_dict.emit(settings_dict)
