extends StaticBody2D

var player: CharacterBody2D
@onready var ui_task_caravan: PanelContainer = $CanvasLayer/ui_task_caravan
@onready var area: Area2D = $Area2D
@onready var door: AnimatedSprite2D = $AnimatedSprite2D

var in_area: bool

func _ready() -> void:
    player = get_tree().get_first_node_in_group("Player")
    if player:
        player.interact.connect(_on_player_interact)
    area.body_entered.connect(_player_entered)
    area.body_exited.connect(_player_exited)

func _player_entered(body: Node2D):
    if body.is_in_group("Player"):
        in_area = true
        door.play("open")

func _player_exited(body: Node2D):
    if body.is_in_group("Player"):
        in_area = false
        door.play_backwards("open")
        ui_task_caravan.hide()

func _on_player_interact():
    if in_area:
        if ui_task_caravan.visible:
            ui_task_caravan.hide()
        else:
            ui_task_caravan.show()
