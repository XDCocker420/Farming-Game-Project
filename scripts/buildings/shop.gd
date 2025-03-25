extends StaticBody2D


@onready var player: CharacterBody2D = %Player
@onready var door: Area2D = $door
@onready var door_sprite: AnimatedSprite2D = $door/AnimatedSprite2D
@onready var ui_shop: PanelContainer = $CanvasLayer/ui_shop

var player_in_area: bool = false


func _ready() -> void:
	player.interact.connect(_on_player_interact)
	door.body_entered.connect(_on_player_entered)
	door.body_exited.connect(_on_player_exited)
	
	
func _on_player_interact() -> void:
	if player_in_area:
		if ui_shop.visible == true:
			ui_shop.hide()
		else:
			ui_shop.show()
	
	
func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		door_sprite.play("open")
	

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		door_sprite.play_backwards("open")
