extends Node2D


@onready var ui_markt: PanelContainer = $ui_markt
@onready var ui_selection: PanelContainer = $ui_selection


func _ready() -> void:
    ui_markt.markt_select.connect(_on_select)
    

func _on_select(slot):
    print(slot)
