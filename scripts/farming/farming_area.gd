extends Area2D


var in_area: bool = false


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = true


func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = false
