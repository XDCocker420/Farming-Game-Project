extends Area2D

var in_area: bool = false
var current_mode: String = ""
var is_current_area: bool = false

@onready var ui_farming = $FarmingUI
@onready var plant_mode_ui = $PlantModeUI
@onready var water_mode_ui = $WaterModeUI
@onready var harvest_mode_ui = $HarvestModeUI

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	ui_farming.visible = false
	plant_mode_ui.visible = false
	water_mode_ui.visible = false
	harvest_mode_ui.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and current_mode != "": # ESC key
		exit_mode()
	elif event.is_action_pressed("ui_accept") and is_current_area and current_mode == "": # E key when no mode active
		if ui_farming.visible:
			ui_farming.hide_ui()
		else:
			ui_farming.show_ui()

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
		ui_farming.hide_ui()

func enter_mode(mode: String) -> void:
	current_mode = mode
	
	# Hide all mode UIs
	plant_mode_ui.visible = false
	water_mode_ui.visible = false
	harvest_mode_ui.visible = false
	
	# Show the corresponding mode UI
	match mode:
		"pflanzen":
			plant_mode_ui.visible = true
		"gießen":
			water_mode_ui.visible = true
		"ernten":
			harvest_mode_ui.visible = true
	
	# Set mode for all fields
	var fields = get_tree().get_nodes_in_group("fields")
	for field in fields:
		if field.has_method("set_mode"):
			field.set_mode(mode)

func exit_mode() -> void:
	current_mode = ""
	
	# Hide all mode UIs
	plant_mode_ui.visible = false
	water_mode_ui.visible = false
	harvest_mode_ui.visible = false
	
	# Reset mode for all fields
	var fields = get_tree().get_nodes_in_group("fields")
	for field in fields:
		if field.has_method("set_mode"):
			field.set_mode("")
	
	# Show the UI again
	if is_current_area:
		ui_farming.show_ui()
