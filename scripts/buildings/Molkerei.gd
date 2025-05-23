extends StaticBody2D

@onready var player: CharacterBody2D = %Player
@onready var door_area: Area2D = $DoorArea
@onready var door: AnimatedSprite2D = $Door
@onready var building_label: Label = $MolkereiLabel # Reference to the label

var in_door_area = false
var interior_scene_path = "res://scenes/buildings/Molkerei_interior.tscn"

func _ready() -> void:
	# Hide label initially
	if building_label:
		building_label.hide()
		
	# Verbinde die Signale
	if player:
		player.interact.connect(_on_player_interact)
	
	door_area.body_entered.connect(_on_door_area_entered)
	door_area.body_exited.connect(_on_door_area_exited)
	
func _on_player_interact() -> void:
	if in_door_area:
		SceneSwitcher.transition_to_new_scene.emit("molkerei", player.global_position)

func _on_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if LevelingHandler.is_building_unlocked("molkerei"):
			in_door_area = true
			door.play("door")
			# Show label
			if building_label:
				building_label.show()
		else:
			# Display level requirement message if player level is too low
			var required_level = LevelingHandler.get_building_level_needed("molkerei")
			LevelingHandler.emit_signal("not_unlocked", required_level)

func _on_door_area_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_door_area = false
		door.play_backwards("door") 
		# Hide label
		if building_label:
			building_label.hide() 
