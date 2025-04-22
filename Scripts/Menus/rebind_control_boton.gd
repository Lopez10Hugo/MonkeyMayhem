class_name rebind_control

extends Control

@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/Button
var is_listening_for_input = false
@export var action_name : String = "mover_derecha_1"

func _ready() -> void:
	set_process_unhandled_input(false)
	set_action_name()
	set_text_key()

func set_action_name() -> void:
	label.text = "No asignado"
	
	match action_name:
		"mover_derecha_2":
			label.text = "Moverse a la derecha"
		"mover_izquierda_1":
			label.text = "Moverse a la izquierda"
		"saltar_1":
			label.text = "Saltar"
		"trepar_1":
			label.text = "Trepar"

func set_text_key() ->void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	var action_key_code = ""
	
	if action_event is InputEventKey:
		action_key_code = OS.get_keycode_string(action_event.physical_keycode)
		#print("Key code:", action_key_code)
	elif action_event is InputEventJoypadButton:
		#print("Joypad button:", action_event.button_index)
		action_key_code = get_joypad_button_name(action_event.button_index)
	
	button.text = "%s" % action_key_code

func get_joypad_button_name(index: int) -> String:
	match index:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_DPAD_UP: return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"
		_: return "Botón " + str(index)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		button.text = "Presiona alguna tecla..."
		is_listening_for_input = true
		set_process_unhandled_key_input(toggled_on)
		
		for i in get_tree().get_first_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_first_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
			
		set_text_key()

func _unhandled_key_input(event: InputEvent) -> void:
	if not is_listening_for_input:
		pass
	else:
		rebind_action_key(event)
		button.button_pressed = false

func rebind_action_key(evento):
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name,evento)
	set_process_unhandled_key_input(false)
	set_text_key()
	set_action_name()

func _on_focus_entered() -> void:
	print('button grabbed focus')
	button.grab_focus()
