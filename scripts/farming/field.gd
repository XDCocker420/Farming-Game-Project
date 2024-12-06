extends Area2D

var current_mode: String = ""

@onready var carrot_scene = preload("res://scenes/crops/carrot.tscn")
@onready var selection_highlight = $SelectionHighlight

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	add_to_group("fields")
	_setup_highlight()

func _setup_highlight() -> void:
	if not has_node("SelectionHighlight"):
		var highlight = NinePatchRect.new()
		highlight.name = "SelectionHighlight"
		highlight.texture = preload("res://assets/gui/menu.png")
		highlight.region_rect = Rect2(289, 49, 46, 14)
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlight.modulate = Color(1, 1, 1, 0.2)
		highlight.visible = false
		highlight.size = Vector2(64, 64)
		highlight.position = Vector2(-32, -32)
		add_child(highlight)
		selection_highlight = highlight

func _on_mouse_entered() -> void:
	if current_mode != "":
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			execute_action()
		_show_highlight()

func _on_mouse_exited() -> void:
	selection_highlight.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_mode != "" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		execute_action()

func execute_action() -> void:
	match current_mode:
		"pflanzen":
			_try_plant()
		"gießen":
			_try_water()
		"ernten":
			_try_harvest()

func _try_plant() -> void:
	if not has_node("Carrot"):
		add_child(carrot_scene.instantiate())

func _try_water() -> void:
	var plant = get_node_or_null("Carrot")
	if plant and plant.has_method("water") and plant.water():
		selection_highlight.modulate = Color(0.7, 0.9, 1.0, 0.3)

func _try_harvest() -> void:
	var plant = get_node_or_null("Carrot")
	if plant and plant.has_method("harvest") and plant.has_method("can_harvest") and plant.can_harvest():
		plant.harvest()
		selection_highlight.visible = false

func _show_highlight() -> void:
	selection_highlight.modulate = Color(1, 1, 1, 0.3)
	selection_highlight.visible = true

func set_mode(mode: String) -> void:
	current_mode = mode
	selection_highlight.visible = false
