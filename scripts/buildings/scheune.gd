extends Node2D


@onready var player: CharacterBody2D = %Player
@onready var e_button: AnimatedSprite2D = $AnimatedSprite2D2
@onready var door: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_area: Area2D = $DoorArea
@onready var ui = $UI
@onready var slots = get_node("UI/Menu/ScrollContainer/VBoxContainer/GridContainer")

var in_area = false
var open = false
var max_storage = 10


func _ready() -> void:
	#if not 'inventory' in SaveData.data:
		#SaveData.data['player']['inventory']
	e_button.visible = false

	player.interact.connect(_on_player_interact)
	door_area.body_entered.connect(_on_door_area_body_entered)
	door_area.body_exited.connect(_on_door_area_body_exited)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && in_area:
		#ui_scheune_instance.load_inventory()
		ui.show()


func _on_player_interact():
	if in_area:
		if not open:
			door.play("open")
			open = true
			#ui_scheune_instance.load_inventory()
			load_inventory()
			ui.show()
		else:
			door.play_backwards("open")
			open = false
			
			ui.hide()
			delete_slots()


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
			ui.hide()
			delete_slots()


func load_inventory() -> void:
	var inventory = SaveGame.get_inventory()
	var count = 0
	

	var keys = inventory.keys()
	keys.sort_custom(func(x:String, y:String) -> bool: return inventory[x] > inventory[y])
		
	for item in keys:
		
		var slot = preload("res://scenes/ui/ui_slot.tscn")

		var new_slot = slot.instantiate()

		if new_slot.has_node("Icon"):
			new_slot.get_node("Icon").texture = load("res://assets/gui/icons/" + item + ".png")
			slots.add_child(new_slot)
			
			new_slot.show()
			count = SaveGame.get_item_count(str(item))

			if count >= 1:
				new_slot.get_node("Node2D/amount").text = str(count)
				new_slot.get_node("Node2D/amount").show()
			else:
				new_slot.get_node("Node2D/amount").hide()
	
	
func delete_slots() -> void:
	for slot in slots.get_children():
		slot.queue_free()
		#slots.remove_child(slot)
