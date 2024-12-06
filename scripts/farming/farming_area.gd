extends Area2D

var current_mode: String = ""
var is_current_area: bool = false

@onready var ui_farming = $FarmingUI
@onready var plant_mode_ui = $PlantModeUI
@onready var water_mode_ui = $WaterModeUI
@onready var harvest_mode_ui = $HarvestModeUI

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	_hide_all_uis()

func _input(event: InputEvent) -> void:
	if not is_current_area:
		return
		
	if event.is_action_pressed("ui_cancel") and current_mode != "":
		exit_mode()
	elif event.is_action_pressed("ui_accept") and current_mode == "":
		ui_farming.visible = not ui_farming.visible
		if ui_farming.visible:
			ui_farming.show_ui()
		else:
			ui_farming.hide_ui()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_current_area = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_current_area = false
		if current_mode != "":
			exit_mode()
		ui_farming.hide_ui()

func enter_mode(mode: String) -> void:
	current_mode = mode
	_hide_all_uis()
	_show_mode_ui(mode)
	_update_fields(mode)

func exit_mode() -> void:
	current_mode = ""
	_hide_all_uis()
	_update_fields("")
	
	if is_current_area:
		ui_farming.show_ui()

func _hide_all_uis() -> void:
	ui_farming.visible = false
	plant_mode_ui.visible = false
	water_mode_ui.visible = false
	harvest_mode_ui.visible = false

func _show_mode_ui(mode: String) -> void:
	match mode:
		"pflanzen":
			plant_mode_ui.visible = true
		"gießen":
			water_mode_ui.visible = true
		"ernten":
			harvest_mode_ui.visible = true

func _update_fields(mode: String) -> void:
	var fields = get_tree().get_nodes_in_group("fields")
	for field in fields:
		if field.has_method("set_mode"):
			field.set_mode(mode)
