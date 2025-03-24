extends StaticBody2D


@onready var door: Area2D = $door
@onready var door_sprite: AnimatedSprite2D = $door/AnimatedSprite2D

var player_in_area: bool = false


func _ready() -> void:
    door.body_entered.connect(_on_player_entered)
    door.body_exited.connect(_on_player_exited)
    
    
func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        player_in_area = true
        door_sprite.play("open")
    

func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("Player"):
        player_in_area = false
        door_sprite.play_backwards("open")
