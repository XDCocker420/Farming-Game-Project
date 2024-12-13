extends TextureButton

var selection_highlight: NinePatchRect = null
var is_clicked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_highlight()
	#self.pressed.connect(self._button_pressed)
	self.button_down.connect(self._button_pressed)
	#self.button_up.connect(self._on_button_up)
	#self.pressed.emit()
	#self.mouse_entered.connect(self._on_mouse_entered)
	#self.mouse_exited.connect(self._on_mouse_exited)
	pass # Replace with function body.
	
func _setup_highlight() -> void:
	selection_highlight = NinePatchRect.new()
	selection_highlight.name = "SelectionHighlight"
	selection_highlight.texture = preload("res://assets/gui/menu.png")
	selection_highlight.region_rect = Rect2(305, 81, 14, 14)
	selection_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_highlight.modulate = Color(1, 1, 1, 0.4)
	selection_highlight.visible = false
	selection_highlight.size = Vector2(29, 29)
	selection_highlight.position = Vector2(-2, -1.6)
	add_child(selection_highlight)
	
func _show_highlight() -> void:
	selection_highlight.visible = true
	if selection_highlight.modulate != Color(0, 0.5, 1, 0.6):
		selection_highlight.modulate = Color(1, 1, 1, 0.5)

func _on_mouse_exited() -> void:
	selection_highlight.visible = false
	
func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("yeah yeah")
	_show_highlight()

func _on_button_up():
	selection_highlight.visible = false

func _button_pressed():
	selection_highlight.visible = true
	"""
	if !is_clicked:
		selection_highlight.visible = true
	else:
		selection_highlight.visible = false
	is_clicked = !is_clicked
	if selection_highlight.modulate != Color(0, 0.5, 1, 0.6):
		selection_highlight.modulate = Color(1, 1, 1, 0.5)
	"""
