extends PanelContainer

@onready var name_label = $Node2D/name

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_icon_mouse_entered() -> void:
	var icon_name = $Icon.texture.get_path().get_file().get_basename()
	name_label.text = CropManager.get_display_name(icon_name)
	name_label.show()

func _on_icon_mouse_exited() -> void:
	name_label.hide() 