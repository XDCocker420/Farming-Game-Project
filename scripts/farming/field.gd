extends Area2D

var is_selected: bool = false
var crop: Node = null
var farming_ui: Node = null

@onready var carrot_scene = preload("res://scenes/crops/carrot.tscn")
@onready var selection_highlight = $SelectionHighlight

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	if not has_node("SelectionHighlight"):
		var highlight = ColorRect.new()
		highlight.name = "SelectionHighlight"
		
		highlight.color = Color(1, 1, 0, 0.3)
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlight.visible = false
		highlight.size = Vector2(64, 64)
		highlight.position = Vector2(-32, -32)
		add_child(highlight)
		selection_highlight = highlight
	
	# Wait for UI to be ready
	call_deferred("_connect_ui")

func _connect_ui() -> void:
	var uis = get_tree().get_nodes_in_group("farming_ui")
	if uis.size() > 0:
		farming_ui = uis[0]
		farming_ui.plant_requested.connect(_on_plant_requested)
		farming_ui.water_requested.connect(_on_water_requested)
		farming_ui.harvest_requested.connect(_on_harvest_requested)
		_update_ui_visibility()

func _any_field_selected() -> bool:
	for field in get_tree().get_nodes_in_group("fields"):
		if field.is_selected:
			return true
	return false

func _update_ui_visibility() -> void:
	if farming_ui:
		if _any_field_selected():
			farming_ui.show_ui()
		else:
			farming_ui.hide_ui()

func _on_mouse_entered() -> void:
	selection_highlight.color = Color(1, 1, 0, 0.5)
	selection_highlight.visible = true

func _on_mouse_exited() -> void:
	if not is_selected:
		selection_highlight.visible = false
	else:
		selection_highlight.color = Color(1, 1, 0, 0.3)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_selected = !is_selected
		selection_highlight.visible = is_selected
		_update_ui_visibility()

func _on_plant_requested() -> void:
	if is_selected and not has_node("Carrot"):
		crop = carrot_scene.instantiate()
		add_child(crop)
		print("Plant planted!")

func _on_water_requested() -> void:
	if is_selected and has_node("Carrot"):
		var plant = get_node("Carrot")
		if plant.has_method("water"):
			if plant.water():
				selection_highlight.color = Color(0, 0, 1, 0.3)
				print("Field watered!")

func _on_harvest_requested() -> void:
	if is_selected and has_node("Carrot"):
		var plant = get_node("Carrot")
		if plant.has_method("harvest") and plant.has_method("can_harvest"):
			if plant.can_harvest():
				plant.harvest()
				is_selected = false
				selection_highlight.visible = false
				selection_highlight.color = Color(1, 1, 0, 0.3)
				_update_ui_visibility()
