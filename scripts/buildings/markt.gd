extends StaticBody2D


@onready var player: CharacterBody2D = %Player
@onready var ui_markt: PanelContainer = $CanvasLayer/ui_markt
@onready var ui_selection: PanelContainer = $CanvasLayer/ui_selection
@onready var interact_area: Area2D = $interact_area
@onready var door: AnimatedSprite2D = $door

var selected_texture: Texture2D
var selected_slot: PanelContainer

var player_in_area: bool = false


func _ready() -> void:
	player.interact.connect(_on_player_interact)
	interact_area.body_entered.connect(_on_player_entered)
	interact_area.body_exited.connect(_on_player_exited)
	ui_markt.select_item.connect(_on_select)
	ui_selection.put_item.connect(_on_put)
	ui_selection.accept.connect(_on_accept)
	

func _on_player_interact() -> void:
	if player_in_area:
		if ui_markt.visible == true:
			ui_markt.hide()
			ui_selection.hide()
		else:
			ui_markt.show()


func _on_select(slot: PanelContainer) -> void:
	ui_selection.show()
	selected_slot = slot
	

func _on_put(item: Texture2D) -> void:
	selected_texture = item
	

func _on_accept():
	var current_texture: TextureRect = selected_slot.get_node("MarginContainer/item")
	current_texture.texture = selected_texture


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		door.play("open")
	
	
func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		ui_markt.hide()
		ui_selection.hide()
		door.play_backwards("open")
