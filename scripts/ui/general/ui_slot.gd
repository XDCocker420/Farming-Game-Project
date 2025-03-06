extends PanelContainer


signal slot_selection(slot: PanelContainer)
signal item_selection(item_name: String, item_texture: Texture2D)

@onready var button: TextureButton = $button
@onready var item_texture: TextureRect = $MarginContainer/item
var item_name: String

var editable: bool = false


func _ready() -> void:
    button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
    if item_texture.texture != null and editable:
        button.button_pressed = false
        return
    
    slot_selection.emit(self)
    item_selection.emit(item_name, item_texture.texture)
