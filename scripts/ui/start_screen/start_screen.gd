extends Control

@onready var start_button: Button = $start_button
@onready var new_game_button:Button = $NewGameButton
@onready var settings_button:Button = $SettingsButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	new_game_button.pressed.connect(_on_new_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	
func _on_start_pressed():
	pass
	
func _on_new_pressed():
	pass
	
func _on_settings_pressed():
	pass
