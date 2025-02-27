extends PanelContainer


@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var texture_button: TextureButton = $TextureButton

signal selection_slot_select(item: String)

var item_name: String


func _ready() -> void:
    texture_button.pressed.connect(_on_pressed)
    

func _on_pressed():
    selection_slot_select.emit(item_name)
