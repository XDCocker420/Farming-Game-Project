extends PanelContainer


signal slot_selection(slot: PanelContainer)
signal item_selection(item: Texture2D)

@onready var button: TextureButton = $button
@onready var item: TextureRect = $MarginContainer/item


func _ready() -> void:
    #amount.hide()
    button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
    slot_selection.emit(self)
    item_selection.emit(item.texture)
