extends Control


@onready var plant_button: Button = $Panel/VBoxContainer/PlantButton
@onready var water_button: Button = $Panel/VBoxContainer/WaterButton

var current_mode: String = "none"

func _ready() -> void:
    plant_button.pressed.connect(_on_plant_button_pressed)
    water_button.pressed.connect(_on_water_button_pressed)
    visible = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):  # E-Taste
        visible = !visible
        print("Farming UI " + ("sichtbar" if visible else "unsichtbar"))

func _on_plant_button_pressed() -> void:
    if current_mode == "plant":
        current_mode = "none"
        plant_button.button_pressed = false
        print("Pflanz-Modus deaktiviert")
    else:
        current_mode = "plant"
        plant_button.button_pressed = true
        water_button.button_pressed = false
        print("Pflanz-Modus aktiviert")


func _on_water_button_pressed() -> void:
    if current_mode == "water":
        current_mode = "none"
        water_button.button_pressed = false
        print("Gieß-Modus deaktiviert")
    else:
        current_mode = "water"
        water_button.button_pressed = true
        plant_button.button_pressed = false
        print("Gieß-Modus aktiviert")


func get_current_mode() -> String:
    return current_mode