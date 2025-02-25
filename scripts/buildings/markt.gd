extends Node2D


@onready var player: CharacterBody2D = %Player
@onready var ui_markt: PanelContainer = $ui_markt
@onready var ui_selection: PanelContainer = $ui_selection
@onready var markt_area: Area2D = $Area2D

var current_texture: TextureRect
var player_in_area: bool = false


func _ready() -> void:
    player.interact.connect(_on_player_interact)
    ui_markt.markt_select.connect(_on_select)
    ui_selection.selection_select.connect(_on_item_selected)
    markt_area.body_entered.connect(_on_player_entered)
    markt_area.body_exited.connect(_on_player_exited)
    

func _on_player_interact():
    if player_in_area:
        if ui_markt.visible == true:
            ui_markt.hide()
            ui_selection.hide()
        else:
            ui_markt.show()


func _on_select(slot):
    current_texture = slot.get_child(1).get_child(0)
    ui_selection.show()


func _on_item_selected(item: String):
    current_texture.texture = load("res://assets/gui/icons/" + item + ".png")
    ui_selection.hide()


func _on_player_entered(body: Node2D):
    if body.is_in_group("Player"):
        player_in_area = true
    
    
func _on_player_exited(body: Node2D):
    if body.is_in_group("Player"):
        player_in_area = false
        ui_markt.hide()
        ui_selection.hide()
