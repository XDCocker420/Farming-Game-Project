extends Area2D

var current_mode: String = ""
var selection_highlight: NinePatchRect = null

@onready var carrot_scene = preload("res://scenes/crops/carrot.tscn")
@onready var wheat_scene = preload("res://scenes/crops/wheat.tscn")

func _ready() -> void:
	_setup_highlight()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	add_to_group("fields")

func _setup_highlight() -> void:
	var highlight = NinePatchRect.new()
	highlight.name = "SelectionHighlight"
	highlight.texture = preload("res://assets/gui/menu.png")
	highlight.region_rect = Rect2(305, 81, 14, 14)
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight.modulate = Color(1, 1, 1, 0.4)
	highlight.visible = false
	highlight.size = Vector2(64, 64)
	highlight.position = Vector2(-32, -32)
	add_child(highlight)
	selection_highlight = highlight

func _on_mouse_entered() -> void:
	if not current_mode.is_empty():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			execute_action()
		_show_highlight()

func _on_mouse_exited() -> void:
	selection_highlight.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_mode.is_empty() or not event is InputEventMouseButton:
		return
		
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		execute_action()

func execute_action() -> void:
	match current_mode:
		"plant":
			_try_plant()
		"water":
			_try_water()
		"harvest":
			_try_harvest()

func _try_plant() -> void:
	if has_node("Carrot") or has_node("Wheat"):
		return
		
	var crop_scene
	if SaveGame.get_item_count("carrot") > 0:
		crop_scene = carrot_scene
		SaveGame.remove_from_inventory("carrot")
	elif SaveGame.get_item_count("wheat") > 0:
		crop_scene = wheat_scene
		SaveGame.remove_from_inventory("wheat")
	else:
		print("No seeds available!")
		SaveGame.add_to_inventory("carrot", 10) # add 10 carrots for testing
		SaveGame.add_to_inventory("wheat", 10)  # add 10 wheat for testing
		SaveGame.save_game()
		return
		
	add_child(crop_scene.instantiate())
	selection_highlight.modulate = Color(1, 1, 1, 0.4)
	selection_highlight.visible = true

func _try_water() -> void:
	var crop = _get_current_crop()
	if crop and crop.has_method("water") and crop.water():
		selection_highlight.modulate = Color(0, 0.5, 1, 0.6)
		selection_highlight.visible = true

func _try_harvest() -> void:
	var crop = _get_current_crop()
	if crop and crop.has_method("harvest") and crop.has_method("can_harvest") and crop.can_harvest():
		crop.harvest()
		selection_highlight.modulate = Color(1, 1, 1, 0.4)
		selection_highlight.visible = false

func _get_current_crop() -> Node:
	return get_node_or_null("Carrot") if has_node("Carrot") else get_node_or_null("Wheat")

func _show_highlight() -> void:
	if not selection_highlight.modulate == Color(0, 0.5, 1, 0.6):
		selection_highlight.modulate = Color(1, 1, 1, 0.5)
	selection_highlight.visible = true

func set_mode(mode: String) -> void:
	current_mode = mode
	selection_highlight.visible = false
