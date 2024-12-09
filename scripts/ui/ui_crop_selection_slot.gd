extends PanelContainer

func _ready() -> void:
	pass

func _on_icon_mouse_entered() -> void:
	var name_label = $Node2D/name
	var icon_name = $Icon.texture.get_path().get_file().get_basename()

	icon_name = icon_name[0].to_upper() + icon_name.substr(1,-1)
	name_label.text = icon_name
	name_label.show()

func _on_icon_mouse_exited() -> void:
	$Node2D/name.hide() 