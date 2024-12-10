extends Area2D

var current_mode: String = ""
var current_crop_type: String = ""
var selection_highlight: NinePatchRect = null
var can_interact: bool = true

var crop_scenes = {
	"carrot": preload("res://scenes/crops/carrot.tscn"),
	"wheat": preload("res://scenes/crops/wheat.tscn"),
	"corn": preload("res://scenes/crops/corn.tscn"),
	"cauliflower": preload("res://scenes/crops/cauliflower.tscn"),
	"berry": preload("res://scenes/crops/berry.tscn"),
	"onion": preload("res://scenes/crops/onion.tscn"),
	"bean": preload("res://scenes/crops/bean.tscn"),
	"grape": preload("res://scenes/crops/grape.tscn")
}

func _ready() -> void:
	_setup_highlight()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	add_to_group("fields")

func _setup_highlight() -> void:
	selection_highlight = NinePatchRect.new()
	selection_highlight.name = "SelectionHighlight"
	selection_highlight.texture = preload("res://assets/gui/menu.png")
	selection_highlight.region_rect = Rect2(305, 81, 14, 14)
	selection_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_highlight.modulate = Color(1, 1, 1, 0.4)
	selection_highlight.visible = false
	selection_highlight.size = Vector2(64, 64)
	selection_highlight.position = Vector2(-32, -32)
	add_child(selection_highlight)

func _on_mouse_entered() -> void:
	if not current_mode.is_empty() and can_interact:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			execute_action()
		_show_highlight()

func _on_mouse_exited() -> void:
	selection_highlight.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_interact and not current_mode.is_empty():
		execute_action()

func execute_action() -> void:
	match current_mode:
		"plant": _try_plant()
		"water": _try_water()
		"harvest": _try_harvest()

func update_field_state(mode: String, crop_type: String = "") -> void:
	current_mode = mode
	current_crop_type = crop_type
	selection_highlight.visible = false
	can_interact = false
	await get_tree().create_timer(0.1).timeout
	can_interact = true

func _try_plant() -> void:
	if _get_current_crop() or current_crop_type.is_empty():
		return
		
	if SaveGame.get_item_count(current_crop_type) > 0 and current_crop_type in crop_scenes:
		SaveGame.remove_from_inventory(current_crop_type)
		add_child(crop_scenes[current_crop_type].instantiate())
		selection_highlight.modulate = Color(1, 1, 1, 0.4)
		selection_highlight.visible = true

func _try_water() -> void:
	var crop = _get_current_crop()
	if crop and crop.has_method("water") and crop.water():
		selection_highlight.modulate = Color(0, 0.5, 1, 0.6)
		selection_highlight.visible = true

func _try_harvest() -> void:
	var crop = _get_current_crop()
	if crop and crop.has_method("can_harvest") and crop.can_harvest():
		crop.harvest()
		selection_highlight.modulate = Color(1, 1, 1, 0.4)
		selection_highlight.visible = false

func _get_current_crop() -> Node:
	for crop_type in crop_scenes.keys():
		var node = get_node_or_null(crop_type.capitalize())
		if node:
			return node
	return null

func _show_highlight() -> void:
	selection_highlight.visible = true
	if selection_highlight.modulate != Color(0, 0.5, 1, 0.6):
		selection_highlight.modulate = Color(1, 1, 1, 0.5)
