extends Sprite2D


@onready var player: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
@onready var farming_area: Area2D = get_parent().get_parent()
@onready var field_area: Area2D = $Area2D
@onready var carrot_scene = preload("res://scenes/crops/carrot.tscn")

var mouse_in_area: bool = false
var crop: Node


func _ready() -> void:
    player.interact2.connect(_on_player_interact)
    field_area.mouse_entered.connect(_on_mouse_entered)
    field_area.mouse_exited.connect(_on_mouse_exited)

    crop = get_node_or_null("Carrot")


func _on_player_interact():
    if farming_area.in_area and mouse_in_area:
        if crop and crop.state == 2:
            harvest()
        else:
            plant()


func _on_mouse_entered():
    mouse_in_area = true


func _on_mouse_exited():
    mouse_in_area = false


func plant() -> void:
    crop = carrot_scene.instantiate()
    add_child(crop)
    SaveGame.remove_from_inventory("carrot")


func harvest() -> void:
    crop.queue_free()     
    crop = null
