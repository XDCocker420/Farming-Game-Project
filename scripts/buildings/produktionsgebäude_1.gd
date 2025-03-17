extends StaticBody2D

@onready var player: CharacterBody2D = %Player
@onready var door_area: Area2D = $DoorArea
@onready var garage_door_area: Area2D = $GarageDoorArea
@onready var door: AnimatedSprite2D = $Door
@onready var garage_door: AnimatedSprite2D = $GarageDoor

var in_door_area = false
var in_garage_door_area = false
var in_dach_area = false
var interior_scene_path = "res://scenes/buildings/produktionsgebäude_interior_1.tscn"

func _ready() -> void:
    print("=== Produktionsgebäude 1 initialisiert ===")
    
    # Verzögerung, um sicherzustellen, dass der Player vollständig geladen ist
    await get_tree().create_timer(0.2).timeout
    
    # Überprüfe, ob der Player gefunden wurde
    if not player:
        push_error("Player nicht gefunden! Stelle sicher, dass er als %Player markiert ist.")
        # Versuche, den Player aus der Gruppe zu bekommen
        var found_player = get_tree().get_first_node_in_group("Player")
        if found_player:
            print("Player in Gruppe gefunden, verwende diesen stattdessen")
            player = found_player
        else:
            print("Kein Player gefunden, weder als %Player noch in Gruppe!")
            return
        
    # Überprüfe, ob die Tür-Areas existieren
    if not door_area:
        push_error("DoorArea nicht gefunden!")
    if not garage_door_area:
        push_error("GarageDoorArea nicht gefunden!")
        
    # Überprüfe, ob die Animation existiert
    if not door:
        push_error("Door AnimatedSprite2D nicht gefunden!")
    if not garage_door:
        push_error("GarageDoor AnimatedSprite2D nicht gefunden!")
    
    # Vergewissere dich, dass der Player in der richtigen Gruppe ist
    if not player.is_in_group("Player"):
        print("Player ist nicht in der 'Player'-Gruppe! Füge ihn hinzu.")
        player.add_to_group("Player")
    
    # Verbinde die Signale
    player.interact.connect(_on_player_interact)
    
    door_area.body_entered.connect(_on_door_area_body_entered)
    door_area.body_exited.connect(_on_door_area_body_exited)
    
    garage_door_area.body_entered.connect(_on_garage_door_area_entered)
    garage_door_area.body_exited.connect(_on_garage_door_area_exited)
    
    # Manuell prüfen, ob der Player bereits im Bereich ist
    # (Dies kann notwendig sein, wenn die Szene nach dem Player geladen wird)
    await get_tree().create_timer(0.2).timeout
    _check_player_in_areas()

func _check_player_in_areas() -> void:
    # Prüfe, ob der Player bereits in einem der Bereiche ist
    var overlapping_door_bodies = door_area.get_overlapping_bodies()
    var overlapping_garage_bodies = garage_door_area.get_overlapping_bodies()
    
    for body in overlapping_door_bodies:
        if body == player:
            _on_door_area_body_entered(body)
    
    for body in overlapping_garage_bodies:
        if body == player:
            _on_garage_door_area_entered(body)

func _on_player_interact() -> void:
    print("Produktionsgebäude: Player interacted")
    if in_door_area:
        print("Produktionsgebäude: Player in door area, entering building")
        # Speichere aktuelle Position für später
        var player = get_tree().get_first_node_in_group("Player")
        if player:
            SaveGame.last_exterior_position = player.global_position
            print("Produktionsgebäude: Saved player position: ", SaveGame.last_exterior_position)
            
        # Wechsle zur Innenraum-Szene
        get_tree().change_scene_to_file("res://scenes/buildings/produktionsgebäude_interior_1.tscn")
    elif in_garage_door_area:
        print("Produktionsgebäude: Player in garage area, entering building")
        # Speichere aktuelle Position für später
        var player = get_tree().get_first_node_in_group("Player")
        if player:
            SaveGame.last_exterior_position = player.global_position
            print("Produktionsgebäude: Saved player position: ", SaveGame.last_exterior_position)
            
        # Wechsle zur Innenraum-Szene
        get_tree().change_scene_to_file("res://scenes/buildings/produktionsgebäude_interior_2.tscn")
    elif in_dach_area:
        print("Produktionsgebäude: Player in roof area, entering building")
        # Speichere aktuelle Position für später
        var player = get_tree().get_first_node_in_group("Player")
        if player:
            SaveGame.last_exterior_position = player.global_position
            print("Produktionsgebäude: Saved player position: ", SaveGame.last_exterior_position)
            
        # Wechsle zur Innenraum-Szene
        get_tree().change_scene_to_file("res://scenes/buildings/produktionsgebäude_interior_3.tscn")

func _on_door_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        print("Produktionsgebäude: Player entered door area")
        in_door_area = true
        door.play("door")

func _on_door_area_body_exited(body: Node2D) -> void:
    if body.is_in_group("Player"):
        print("Produktionsgebäude: Player exited door area")
        in_door_area = false
        door.play_backwards("door")

func _on_garage_door_area_entered(body: Node2D) -> void:
    if body == player:
        in_garage_door_area = true
        garage_door.play("GarageDoor")
        print("Player hat Garagen-Bereich betreten")

func _on_garage_door_area_exited(body: Node2D) -> void:
    if body == player:
        in_garage_door_area = false
        garage_door.play_backwards("GarageDoor")
        print("Player hat Garagen-Bereich verlassen") 