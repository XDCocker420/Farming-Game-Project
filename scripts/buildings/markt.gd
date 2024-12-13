extends Node2D


@onready var market_area: Area2D = $Area2D
@onready var player: CharacterBody2D = %Player
@onready var ui_markt: Control = $ui_markt

var player_in_area: bool = false

func _ready() -> void:
    market_area.body_entered.connect(_on_player_entered)
    market_area.body_exited.connect(_on_player_exited)
    player.interact.connect(_on_player_interact)
    ui_markt.visible = false


func _on_player_entered(body: Node2D):
    if body.is_in_group("Player"):
        player_in_area = true
    
    
func _on_player_exited(body: Node2D):
    if body.is_in_group("Player"):
        player_in_area = false
        ui_markt.visible = false


func _on_player_interact():
    if player_in_area:
        if ui_markt.visible == true:
            ui_markt.visible = false
        else:
            ui_markt.visible = true
