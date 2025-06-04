extends Label

# The parent slot that this label belongs to
@onready var parent_slot = get_parent()

func _ready():
	# Initialize as hidden
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Connect hover signals from parent slot's button
	if parent_slot.has_node("button"):
		var button = parent_slot.get_node("button")
		if not button.mouse_entered.is_connected(_on_button_mouse_entered):
			button.mouse_entered.connect(_on_button_mouse_entered)
		if not button.mouse_exited.is_connected(_on_button_mouse_exited):
			button.mouse_exited.connect(_on_button_mouse_exited)

# Called when mouse enters the slot button
func _on_button_mouse_entered():
	if parent_slot.locked or parent_slot.item_name == "":
		return

	var total_price: int = parent_slot.price
	if total_price > 0:
		text = str(total_price) + "$"
		visible = true

func _on_button_mouse_exited():
	visible = false
