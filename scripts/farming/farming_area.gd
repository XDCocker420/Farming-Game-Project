extends Area2D

var in_area: bool = false
var current_mode: String = ""
var is_current_area: bool = false

@onready var mode_label: Label = $ModeLabel
@onready var farming_ui = $FarmingUI

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	mode_label.visible = false
	farming_ui.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and current_mode != "": # ESC-Taste
		exit_mode()
	elif event.is_action_pressed("ui_accept") and is_current_area: # E-Taste
		if farming_ui.visible:
			farming_ui.hide_ui()
		else:
			farming_ui.show_ui()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = true
		is_current_area = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = false
		is_current_area = false
		if current_mode != "":
			exit_mode()
		farming_ui.hide_ui()

func enter_mode(mode: String) -> void:
	current_mode = mode
	mode_label.text = mode.capitalize() + " Modus"
	mode_label.visible = true
	
	# Setze den Modus für alle Felder
	var fields = get_tree().get_nodes_in_group("fields")
	for field in fields:
		if field.has_method("set_mode"):
			field.set_mode(mode)

func exit_mode() -> void:
	current_mode = ""
	mode_label.visible = false
	
	# Setze den Modus für alle Felder zurück
	var fields = get_tree().get_nodes_in_group("fields")
	for field in fields:
		if field.has_method("set_mode"):
			field.set_mode("")
	
	# Zeige das UI wieder an, anstatt es komplett zu schließen
	if is_current_area:
		farming_ui.show_ui()
