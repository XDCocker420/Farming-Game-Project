extends Control

@onready var plant_button: Button = $Panel/VBoxContainer/PlantButton
@onready var water_button: Button = $Panel/VBoxContainer/WaterButton
@onready var harvest_button: Button = $Panel/VBoxContainer/HarvestButton

signal plant_requested
signal water_requested
signal harvest_requested

func _ready() -> void:
    plant_button.pressed.connect(_on_plant_button_pressed)
    water_button.pressed.connect(_on_water_button_pressed)
    harvest_button.pressed.connect(_on_harvest_button_pressed)
    visible = false

func _on_plant_button_pressed() -> void:
    emit_signal("plant_requested")
    print("Pflanz-Aktion angefordert")

func _on_water_button_pressed() -> void:
    emit_signal("water_requested")
    print("Gieß-Aktion angefordert")

func _on_harvest_button_pressed() -> void:
    emit_signal("harvest_requested")
    print("Ernte-Aktion angefordert")

func show_ui() -> void:
    visible = true
    
func hide_ui() -> void:
    visible = false