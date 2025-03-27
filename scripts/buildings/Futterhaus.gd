extends StaticBody2D

@onready var player: CharacterBody2D = %Player
@onready var door_area: Area2D = $DoorArea
@onready var garage_door_area: Area2D = $GarageDoorArea
@onready var door: AnimatedSprite2D = $Door
@onready var garage_door: AnimatedSprite2D = $GarageDoor

var in_door_area = false
var in_garage_door_area = false
var interior_scene_path = "res://scenes/buildings/Futterhaus_interior.tscn"

func _ready() -> void:
	# Verbinde die Signale
	player.interact.connect(_on_player_interact)
	
	door_area.body_entered.connect(_on_door_area_entered)
	door_area.body_exited.connect(_on_door_area_exited)
	
	garage_door_area.body_entered.connect(_on_garage_door_area_entered)
	garage_door_area.body_exited.connect(_on_garage_door_area_exited)

func _process(_delta: float) -> void:
	# Überprüfe Interaktions-Hinweise
	if is_instance_valid(player) and player.has_method("set_interaction_hint"):
		if in_door_area:
			player.set_interaction_hint("Drücke E zum Betreten des Futterhauses")
		elif in_garage_door_area:
			player.set_interaction_hint("Drücke E zum Betreten der Futterhaus-Garage")
		else:
			player.set_interaction_hint("")

func _on_player_interact() -> void:
	if in_door_area or in_garage_door_area:
		# Speichere die aktuelle Position des Spielers
		SaveGame.set_last_exterior_position(player.global_position)
		# Wechsle zur Innenszene
		get_tree().change_scene_to_file(interior_scene_path)

func _on_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_door_area = true
		door.play("door")

func _on_door_area_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_door_area = false
		door.play_backwards("door")

func _on_garage_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_garage_door_area = true
		if garage_door and garage_door.sprite_frames.has_animation("GarageDoor"):
			garage_door.play("GarageDoor")

func _on_garage_door_area_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_garage_door_area = false
		if garage_door and garage_door.sprite_frames.has_animation("GarageDoor"):
			garage_door.play_backwards("GarageDoor") 