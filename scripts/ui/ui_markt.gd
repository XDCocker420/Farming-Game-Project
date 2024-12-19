extends Control


@onready var top_row: HBoxContainer = $NinePatchRect/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer
@onready var bottom_row: HBoxContainer = $NinePatchRect/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2
@onready var crop_selection_ui: Control = $CropSelectionUI

@onready var top_row_children = top_row.get_children()
@onready var bottom_row_children = bottom_row.get_children()

var id_clicked: int


func _ready() -> void:
    var i: int = 0

    for child in top_row_children:
        child.set_id(i)
        i += 1
        child.clicked.connect(_on_market_slot_clicked)

    for child in bottom_row_children:
        child.set_id(i)
        i += 1
        child.clicked.connect(_on_market_slot_clicked)

    crop_selection_ui.crop_selected.connect(_on_crop_selected)

    bottom_row_children[2].open = false
    bottom_row_children[3].open = false
    top_row_children[2].open = false
    top_row_children[3].open = false


func change_visible() -> void:
    if visible == true:
        visible = false
    else:
        visible = true
        for child in top_row_children:
            child.ui_opened()

        for child in bottom_row_children:
            child.ui_opened()


func _on_market_slot_clicked(id: int) -> void:
    crop_selection_ui.visible = true
    id_clicked = id


func _on_crop_selected(crop_type: String) -> void:
    if id_clicked < 4:
        top_row_children[id_clicked].set_icon("res://assets/gui/icons/" + crop_type + ".png")
        top_row_children[id_clicked].occupied = true
    else:
        bottom_row_children[id_clicked - 4].set_icon("res://assets/gui/icons/" + crop_type + ".png")
        bottom_row_children[id_clicked - 4].occupied = true
