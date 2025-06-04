extends StaticBody2D

var player: CharacterBody2D
@onready var door_area: Area2D = $DoorArea
@onready var door: AnimatedSprite2D = $door

var in_door_area = false
var interior_scene_path = "res://scenes/buildings/Pub_interior.tscn"

func _ready() -> void:
        player = get_tree().get_first_node_in_group("Player")
        # Verbinde die Signale
        if player:
                player.interact.connect(_on_player_interact)
	
	door_area.body_entered.connect(_on_door_area_entered)
	door_area.body_exited.connect(_on_door_area_exited)
	
func _on_player_interact() -> void:
	if in_door_area:
		SceneSwitcher.transition_to_new_scene.emit("pub", player.global_position)

func _on_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked("pub"):
		in_door_area = true
		door.play("door")

func _on_door_area_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_door_area = false
		door.play_backwards("door")
