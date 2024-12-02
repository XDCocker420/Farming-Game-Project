extends Area2D

var is_selected: bool = false
var crop: Node = null

@onready var farming_ui = get_tree().get_nodes_in_group("farming_ui")[0]
@onready var carrot_scene = preload("res://scenes/crops/carrot.tscn")
@onready var selection_highlight = $SelectionHighlight

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	farming_ui.plant_requested.connect(_on_plant_requested)
	farming_ui.water_requested.connect(_on_water_requested)
	farming_ui.harvest_requested.connect(_on_harvest_requested)
	
	# Erstelle visuelles Highlight für Auswahl
	if not has_node("SelectionHighlight"):
		var highlight = ColorRect.new()
		highlight.name = "SelectionHighlight"
		highlight.color = Color(1, 1, 0, 0.3)  # Gelb, halbtransparent
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignoriere Maus-Events
		highlight.visible = false
		highlight.size = Vector2(64, 64)  # Größe anpassen
		highlight.position = Vector2(-32, -32)  # Zentrieren
		add_child(highlight)
		selection_highlight = highlight

func _on_mouse_entered() -> void:
	selection_highlight.color = Color(1, 1, 0, 0.5)  # Heller wenn Maus drüber
	selection_highlight.visible = true

func _on_mouse_exited() -> void:
	if not is_selected:
		selection_highlight.visible = false
	else:
		selection_highlight.color = Color(1, 1, 0, 0.3)  # Normales Highlight wenn ausgewählt

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_selected = !is_selected
		selection_highlight.visible = is_selected
		if is_selected:
			farming_ui.show_ui()
		else:
			# Prüfe ob noch andere Felder ausgewählt sind
			var any_selected = false
			for field in get_tree().get_nodes_in_group("fields"):
				if field != self and field.is_selected:
					any_selected = true
					break
			if not any_selected:
				farming_ui.hide_ui()

func _on_plant_requested() -> void:
	if is_selected and not has_node("Carrot"):  # Später: Prüfen welche Pflanze gepflanzt werden soll
		crop = carrot_scene.instantiate()
		add_child(crop)
		print("Pflanze gepflanzt!")

func _on_water_requested() -> void:
	if is_selected and has_node("Carrot"):  # Später: Prüfen welche Pflanze auf dem Feld ist
		var plant = get_node("Carrot")
		if plant.has_method("water"):
			if plant.water():  # Wenn das Gießen erfolgreich war
				selection_highlight.color = Color(0, 0, 1, 0.3)  # Blaues Highlight für gegossene Felder
				print("Feld wurde gegossen!")

func _on_harvest_requested() -> void:
	if is_selected and has_node("Carrot"):  # Später: Prüfen welche Pflanze auf dem Feld ist
		var plant = get_node("Carrot")
		if plant.has_method("harvest") and plant.has_method("can_harvest"):
			if plant.can_harvest():
				plant.harvest()
				is_selected = false
				selection_highlight.visible = false
				selection_highlight.color = Color(1, 1, 0, 0.3)  # Zurück zu gelb
