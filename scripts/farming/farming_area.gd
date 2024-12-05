extends Area2D

var in_area: bool = false
var current_mode: String = ""

@onready var mode_label: Label = $ModeLabel

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	mode_label.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and current_mode != "": # ESC-Taste
		exit_mode()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = false
		if current_mode != "":
			exit_mode()

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
			
	var uis = get_tree().get_nodes_in_group("farming_ui")
	if uis.size() > 0:
		uis[0].show_ui()
