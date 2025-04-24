extends StaticBody2D

@onready var player: CharacterBody2D = %Player
@onready var door_area: Area2D = $DoorArea
@onready var door: AnimatedSprite2D = $Door
@onready var building_label: Label = $WebereiLabel 

var in_door_area = false
var interior_scene_path = "res://scenes/buildings/Weberei_interior.tscn"

func _ready() -> void:
	if building_label:
		building_label.hide()
	# Verbinde die Signale
	if player:
		player.interact.connect(_on_player_interact)
	
	door_area.body_entered.connect(_on_door_area_entered)
	door_area.body_exited.connect(_on_door_area_exited)
	
func _on_player_interact() -> void:
	if in_door_area:
		SceneSwitcher.transition_to_new_scene.emit(name.to_lower(), player.global_position)

func _on_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked("weberei"):
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
