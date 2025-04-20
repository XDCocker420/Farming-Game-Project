extends StaticBody2D

@onready var player: CharacterBody2D = %Player
@onready var door_area: Area2D = $DoorArea
@onready var garage_door_area: Area2D = $GarageDoorArea
@onready var door: AnimatedSprite2D = $Door
@onready var garage_door: AnimatedSprite2D = $GarageDoor

var in_door_area = false
var in_garage_door_area = false

@onready var feed_area: Area2D = $feedArea
@onready var production_ui_feed = $production_ui_feed
@onready var inventory_ui_feed = $inventory_ui_feed
var player_in_feed_area: bool = false

func _ready() -> void:
	# Verbinde die Signale
	if player:
		player.interact.connect(_on_player_interact)
	
	door_area.body_entered.connect(_on_door_area_entered)
	door_area.body_exited.connect(_on_door_area_exited)
	
	garage_door_area.body_entered.connect(_on_garage_door_area_entered)
	garage_door_area.body_exited.connect(_on_garage_door_area_exited)

	# connect feed area
	feed_area.body_entered.connect(_on_feed_area_body_entered)
	feed_area.body_exited.connect(_on_feed_area_body_exited)

	# hide UIs initially
	production_ui_feed.hide()
	inventory_ui_feed.hide()

func _process(_delta: float) -> void:
	pass

func _on_player_interact() -> void:
	# feed area interaction
	if player_in_feed_area:
		if production_ui_feed.visible:
			production_ui_feed.hide()
			inventory_ui_feed.hide()
		else:
			production_ui_feed.show()
			inventory_ui_feed.show()
			production_ui_feed.setup("feed_mill")
			inventory_ui_feed.setup_and_show("feed_mill")
			if inventory_ui_feed.has_method("set_active_production_ui"):
				inventory_ui_feed.set_active_production_ui(production_ui_feed)

func _on_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked("futterhaus"):
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

func _on_feed_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_feed_area = true
		if body.has_method("show_interaction_prompt"):
			body.show_interaction_prompt("Press E to use Feed Mill")

func _on_feed_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_feed_area = false
		production_ui_feed.hide()
		inventory_ui_feed.hide()
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()
