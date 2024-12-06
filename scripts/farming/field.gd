extends Area2D

var is_selected: bool = false
var crop: Node = null
var current_mode: String = ""
var mouse_held: bool = false

@onready var carrot_scene = preload("res://scenes/crops/carrot.tscn")
@onready var selection_highlight = $SelectionHighlight

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	add_to_group("fields")
	
	# Create highlight if it doesn't exist
	if not has_node("SelectionHighlight"):
		var highlight = NinePatchRect.new()
		highlight.name = "SelectionHighlight"
		
		highlight.texture = preload("res://assets/gui/menu.png")
		highlight.region_rect = Rect2(289, 49, 46, 14)
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlight.modulate = Color(1, 1, 1, 0.2)  # Default transparency
		highlight.visible = false
		highlight.size = Vector2(64, 64)
		highlight.position = Vector2(-32, -32)
		add_child(highlight)
		selection_highlight = highlight

func _on_mouse_entered() -> void:
	if current_mode != "":
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			execute_action()
		selection_highlight.modulate = Color(1, 1, 1, 0.3)  # Slightly more visible on hover
		selection_highlight.visible = true

func _on_mouse_exited() -> void:
	selection_highlight.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_mode != "" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			execute_action()

func execute_action() -> void:
	match current_mode:
		"pflanzen":
			if not has_node("Carrot"):
				crop = carrot_scene.instantiate()
				add_child(crop)
		"gießen":
			if has_node("Carrot"):
				var plant = get_node("Carrot")
				if plant.has_method("water"):
					if plant.water():
						selection_highlight.modulate = Color(0.7, 0.9, 1.0, 0.3)  # Blue tint for watered fields
		"ernten":
			if has_node("Carrot"):
				var plant = get_node("Carrot")
				if plant.has_method("harvest") and plant.has_method("can_harvest"):
					if plant.can_harvest():
						plant.harvest()
						selection_highlight.visible = false

func set_mode(mode: String) -> void:
	current_mode = mode
	selection_highlight.visible = false
