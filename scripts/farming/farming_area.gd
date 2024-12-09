extends Area2D

var current_mode: String = ""
var is_current_area: bool = false
var selected_crop: String = ""

@onready var ui_farming = $FarmingUI
@onready var crop_selection_ui = $CropSelectionUI
@onready var mode_uis = {
	"plant": $PlantModeUI,
	"water": $WaterModeUI,
	"harvest": $HarvestModeUI
}

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	crop_selection_ui.crop_selected.connect(_on_crop_selected)
	_hide_all_uis()

func _input(event: InputEvent) -> void:
	if not is_current_area:
		return
		
	if event.is_action_pressed("ui_cancel"):
		if crop_selection_ui.visible:
			crop_selection_ui.hide_ui()
			ui_farming.show_ui()
		elif not current_mode.is_empty():
			exit_mode()
	elif event.is_action_pressed("ui_accept") and current_mode.is_empty():
		_toggle_farming_ui()

func _toggle_farming_ui() -> void:
	if ui_farming.visible:
		ui_farming.hide_ui()
	else:
		ui_farming.show_ui()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_current_area = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_current_area = false
		if not current_mode.is_empty():
			exit_mode()
		_hide_all_uis()

func enter_mode(mode: String) -> void:
	if mode == "plant":
		ui_farming.hide_ui(false)
		crop_selection_ui.show_ui()
		return
		
	current_mode = mode
	selected_crop = ""
	_hide_all_uis()
	_show_mode_ui(mode)
	_update_fields()

func _on_crop_selected(crop_type: String) -> void:
	selected_crop = crop_type
	current_mode = "plant"
	_hide_all_uis()
	_show_mode_ui("plant")
	_update_fields()

func exit_mode() -> void:
	current_mode = ""
	selected_crop = ""
	_hide_all_uis()
	_update_fields()
	
	if is_current_area:
		ui_farming.show_ui()

func _hide_all_uis() -> void:
	ui_farming.visible = false
	crop_selection_ui.visible = false
	for ui in mode_uis.values():
		ui.visible = false

func _show_mode_ui(mode: String) -> void:
	if mode in mode_uis:
		mode_uis[mode].visible = true

func _update_fields() -> void:
	var fields = get_tree().get_nodes_in_group("fields")
	if fields.is_empty():
		return
		
	for field in fields:
		if field.has_method("update_field_state"):
			field.update_field_state(current_mode, selected_crop)

func get_selected_crop() -> String:
	return selected_crop
