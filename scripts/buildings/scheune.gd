extends StaticBody2D


var player: CharacterBody2D
@onready var ui: PanelContainer = $CanvasLayer/ui
@onready var door_area: Area2D = $DoorArea
@onready var door: AnimatedSprite2D = $door

var in_area = false


func _ready() -> void:
        player = get_tree().get_first_node_in_group("Player")
        if player:
                player.interact.connect(_on_player_interact)
	door_area.body_entered.connect(_on_player_entered)
	door_area.body_exited.connect(_on_player_exited)
	
	
func _on_player_interact() -> void:
	if in_area:
		if ui.visible == true:
			ui.hide()
		else:
			ui.show()


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = true
		door.play("open")
		

func _on_player_exited(body: Node2D) ->  void:
	if body.is_in_group("Player"):
		in_area = false
		ui.hide()
		door.play_backwards("open")
