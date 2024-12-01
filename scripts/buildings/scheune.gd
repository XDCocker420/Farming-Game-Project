extends Node2D


@onready var player: CharacterBody2D = %Player
@onready var e_button: AnimatedSprite2D = $AnimatedSprite2D2
@onready var door: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_area: Area2D = $DoorArea
@onready var storage_label: Label = $StorageLabel
@onready var ui = $UI

var in_area = false
var open = false
var max_storage = 10


func _ready() -> void:
    #if not 'inventory' in SaveData.data:
        #SaveData.data['player']['inventory']
    e_button.visible = false
    storage_label.visible = false

    player.interact.connect(_on_player_interact)
    player.interact2.connect(_on_player_interact2)
    door_area.body_entered.connect(_on_door_area_body_entered)
    door_area.body_exited.connect(_on_door_area_body_exited)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("test passed")
		ui.show()


func _on_player_interact():
    if in_area:
        if not open:
            door.play("open")
            open = true
            storage_label.visible = true
            update_storage_text()
        else:
            door.play_backwards("open")
            open = false
            storage_label.visible = false


func _on_player_interact2():
    if in_area and open:
        if SaveGame.get_inventory():
            #SaveData.data['inventory'] -= 1
            update_storage_text()


func update_storage_text() -> void:
    storage_label.text = "Lager: " + str(0) + "/" + str(max_storage)


func _on_door_area_body_entered(body):
    if body.is_in_group("Player"):
        e_button.visible = true
        in_area = true


func _on_door_area_body_exited(body):
    if body.is_in_group("Player"):
        e_button.visible = false
        in_area = false
        
        if open:
            door.play_backwards("open")
            open = false
            storage_label.visible = false
