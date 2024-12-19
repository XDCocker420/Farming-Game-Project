extends TextureButton


signal clicked(id: int)

@onready var icon_button: TextureRect = $icon

var id: int
var open: bool = true
var occupied: bool = false
var closed_texture = preload("res://assets/gui/slot_contractboard_bg.png")


func ui_opened():
    if open == false:
        texture_normal = closed_texture


func _pressed() -> void:
    if open and not occupied:
        clicked.emit(id)


func get_id() -> int:
    return id


func set_id(slot_id: int) -> void:
    id = slot_id


func set_icon(path: String) -> void:
    var texture = load(path)
    icon_button.texture = texture
