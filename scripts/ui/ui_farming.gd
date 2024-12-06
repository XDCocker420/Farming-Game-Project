extends Control

@onready var plant_button: Button = $Menu/PlantButtonField/PlantButton
@onready var water_button: Button = $Menu/WaterButtonField/WaterButton
@onready var harvest_button: Button = $Menu/HarvestButtonField/HarvestButton
@onready var farming_areas = get_tree().get_nodes_in_group("farming_areas")

var current_area: Area2D = null

signal ui_visibility_changed(is_visible: bool)

func _ready() -> void:
	plant_button.pressed.connect(_on_plant_button_pressed)
	water_button.pressed.connect(_on_water_button_pressed)
	harvest_button.pressed.connect(_on_harvest_button_pressed)
	visible = false
	
	# Connect to all farming areas
	for area in farming_areas:
		if area.has_method("_on_player_entered"):
			area.body_entered.connect(_on_farming_area_entered.bind(area))
			area.body_exited.connect(_on_farming_area_exited.bind(area))

func _on_plant_button_pressed() -> void:
	if current_area:
		current_area.enter_mode("pflanzen")
		hide_ui(false)

func _on_water_button_pressed() -> void:
	if current_area:
		current_area.enter_mode("gießen")
		hide_ui(false)

func _on_harvest_button_pressed() -> void:
	if current_area:
		current_area.enter_mode("ernten")
		hide_ui(false)

func _on_farming_area_entered(body: Node2D, area: Area2D) -> void:
	if body.is_in_group("Player"):
		current_area = area

func _on_farming_area_exited(body: Node2D, area: Area2D) -> void:
	if body.is_in_group("Player"):
		hide_ui()
		current_area = null

func show_ui() -> void:
	visible = true
	emit_signal("ui_visibility_changed", true)
	
func hide_ui(emit_signal: bool = true) -> void:
	visible = false
	if emit_signal:
		emit_signal("ui_visibility_changed", false)
