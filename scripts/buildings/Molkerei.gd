extends StaticBody2D

var player: CharacterBody2D
@onready var door_area: Area2D = $DoorArea
@onready var door: AnimatedSprite2D = $Door
@onready var building_label: Label = $MolkereiLabel

var in_door_area = false
var interior_scene_path = "res://scenes/buildings/Molkerei_interior.tscn"

func _ready() -> void:
    player = get_tree().get_first_node_in_group("Player")
    # Hide label initially
    if building_label:
        building_label.hide()
    if player:
        player.interact.connect(_on_player_interact)

    door_area.body_entered.connect(_on_door_area_entered)
    door_area.body_exited.connect(_on_door_area_exited)

func _on_player_interact() -> void:
    if in_door_area:
        SceneSwitcher.transition_to_new_scene.emit("molkerei", player.global_position)

func _on_door_area_entered(body: Node2D) -> void:
    if body.is_in_group("Player") and LevelingHandler.is_building_unlocked("molkerei"):
        in_door_area = true
        door.play("door")
        if building_label:
            building_label.show()

func _on_door_area_exited(body: Node2D) -> void:
    if body.is_in_group("Player"):
        in_door_area = false
        door.play_backwards("door")
        if building_label:
            building_label.hide()
