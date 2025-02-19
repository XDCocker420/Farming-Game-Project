extends PanelContainer


@onready var texture_button: TextureButton = $TextureButton
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect


func _ready() -> void:
    texture_button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
    texture_rect.texture = load("res://assets/gui/icons/carrot.png")
